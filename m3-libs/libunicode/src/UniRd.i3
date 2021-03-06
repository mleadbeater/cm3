(* Copyright (C) Rodney M. Bates 2016. *)
(* rodney.m.bates@acm.org *) 
(* Licensed under the MIT License. *) 

INTERFACE UniRd 

(* Synchronized reader for a stream with one of several character encodings. 
   This runs as a filter, reading bytes from an Rd.T, named "Source".  It
   locks Source during any individual operation of this interface.  It is
   possible bypass a UniRd.T and directly operate on its Source, but think 
   about the synchronization consequences.  
  
   This is quite similar to Rd, but there is an essential difference.
   In Rd, when a procedures has "Wide" in its name, it means both: 
     1) The character(s) read are returned in variables of type WIDECHAR, and 
     2) The encoding in the stream consists of exactly two bytes, LSB first,
        for each character.  
   Similarly, for non-wide, the value is retuned in a CHAR, and one byte is
   read from the stream. 

   In UniRd, "Wide" has only meaning 1).  The encoding is taken from the Stream.
   Procedures that return results in variables of type CHAR raise Range, if the 
   decoded character from the stream is not in CHAR.

   If compiled with ORD(LAST(WIDECHAR)) = 16_FFFF (i.e., 16-bit WIDECHAR), any
   encoded value beyond this range is converted to the Unicode substitution
   character W'\U00FFFD' and so returned.  
*)  

; IMPORT Rd 
; FROM Rd IMPORT EndOfFile , Failure 
; FROM Thread IMPORT Alerted 
; FROM UniCodec IMPORT Widechar  
; FROM UniEncoding IMPORT Encoding  
; IMPORT Word 

; TYPE RangeInfo = RECORD Wch: Widechar ; Location : CARDINAL END 

; EXCEPTION Range ( RangeInfo )  

; TYPE T <: ROOT 

; PROCEDURE Init ( Stream : T ; Source : Rd . T ; Dec : Encoding ) : T  
  (* Initialize Stream to write to Source in encoding Dec, then return it. *) 

; PROCEDURE New ( Source : Rd . T ; Dec : Encoding ) : T 
  (* Equivalent to Init(NEW(T),Source,Dec) *)  

; PROCEDURE Source ( Stream : T ) : Rd . T 
  (* The Rd.T used by Stream. *) 

; PROCEDURE Enc ( Stream : T ) : Encoding 
  (* The encoding used by Stream. *) 

; PROCEDURE EOF ( Stream : T ) : BOOLEAN 
  RAISES { Failure , Alerted } 
  (* TRUE iff Stream is at end-of-file. *) 

; PROCEDURE CharsReady ( Stream : T ) : CARDINAL 
  RAISES { Failure } 
  (* A number of characters that can be read without indefinite waiting.
     The EOF counts as one "character" here.  This number may very pessimistic. 
  *) 

; PROCEDURE GetWideChar ( Stream : T ) : Widechar  
  RAISES { EndOfFile , Failure , Alerted } 
  (* Decode, consume, and return a character from Source(Stream), 
     using Enc(Stream) 
  *) 
  
; CONST (* PROCEDURE *) GetChar = GetWideChar  
   (* With return by value and CHAR assignable to WIDECHAR, only one procedure 
      is needed. *) 

; PROCEDURE UnGetCodePoint ( Stream : T ) : BOOLEAN (* Succeeded. *) 
  (* Push back the last decoded code point read from Stream, pushing it back
     onto Stream.Source, in encoded form.  This is guaranteed to work only
     if the last operation on Stream was GetWideChar, GetChar, GetWideSub,
     or GetSub, or an UnsafeUniRd.Fast* version thereof.  Result FALSE means 
     the operation did not happen, because of a violation of this condition,
     or because somebody has bypassed Stream and directly [un]gotten chars
     from Stream.Source.
  *) 
  
; PROCEDURE GetWideSub ( Stream : T ; VAR (*OUT*) ArrWch : ARRAY OF Widechar ) 
  : CARDINAL
  RAISES { Failure , Alerted } 
  (* Decode and consume characters from Source(Stream), using Enc(Stream), 
     storing them into ArrWch, until Source(Stream) is at end-of-file, or ArrWch
     is filled.  Return the actual number of decoded characters stored 
     into ArrWch. *)  

; PROCEDURE GetSub ( Stream : T ; VAR (*OUT*) ArrCh : ARRAY OF CHAR ) : CARDINAL
  RAISES { Range , Failure , Alerted } 
  (* Decode and consume characters from Source(Stream), using Enc(Stream), 
     storing them into ArrCh, until Source(Stream) is at end-of-file, or ArrCh
     is filled, or a decoded character value is not in CHAR.  In the latter 
     case, consume but do not store the problem character and raise
     Range({Wch,N}), where Wch is the problem character and N is the number of 
     previous characters stored.  Otherwise, return the actual number of 
     decoded characters stored into ArrCh. *)  

; PROCEDURE GetWideSubLine 
    ( Stream : T ; VAR (*OUT*) ArrWch : ARRAY OF Widechar ) 
  : CARDINAL
  RAISES { Failure , Alerted } 
  (* Decode and consume characters from Source(Stream), using Enc(Stream), 
     storing them into ArrWch, until Source(Stream) is at end-of-file, or 
     ArrWch is filled, or an end-of-line sequence has been read.  
     Return the actual number of decoded characters stored into ArrWch.  
     Include any end-of-line sequence in the returned count and store it in
     ArrWch, except if only one character of a two-character end-of-line 
     sequence would fit in ArrWch, leave both unstored and unconsumed. 

     Consistent with the Unicode standard, an end-of-line consists of any of:

       LF =  W'\x000A' = W'\n'  
       CR =  W'\x000D' = W'\r'  
       CR immediately followed by LF 
       FF =  W'\x000C' = W'\f'  
       VT =  W'\x0009' = W'\t'  
       NEL = W'\x0085'  
       LS =  W'\x2028'  
       PS =  W'\x2029'  

     If only one character of a two-character end-of-line sequence would fit 
     in ArrWch, leave both unstored and unconsumed. 
  *) 

; PROCEDURE GetSubLine 
    ( Stream : T ; VAR (*OUT*) ArrCh : ARRAY OF CHAR ) : CARDINAL
  RAISES { Range , Failure , Alerted } 
  (* Like FastGetWideSubLine, but return stored characters in an ARRAY OF CHAR.
     If an otherwise to-be-returned character is not in CHAR, consume but do
     not store it and raise Range(Wch,N), where Wch is the out-of-range 
     character, and N is the number of characters stored.  
  *) 

; PROCEDURE GetText ( Stream : T ; Len : CARDINAL ) : TEXT  
  RAISES { Failure , Alerted }
  (* Decode and consume  characters from Source(Stream), using Enc(Stream), 
     until Len characters have been decoded or Source(Stream) is at 
     end-of-file.  Return the decoded characters as a TEXT. 
  *) 

; CONST (* PROCEDURE *) GetWideText = GetText 
  (* Wide/narrow is hidden inside TEXT.  Either procedure does the same. *) 

; PROCEDURE GetLine ( Stream : T ) : TEXT 
  RAISES { EndOfFile , Failure , Alerted }
  (* Like GetWideSubLine, but return the decoded string in a TEXT, with no
     size limit.  Unlike Rd.GetLine, do include the end-of-line sequence,
     if it exists in Stream, at the end of the returned TEXT.  You may need
     this to know which EOL sequence it was.  
  *) 

; PROCEDURE Close ( Stream : T ) RAISES { Failure , Alerted }
  (* Close Stream and its source. *) 

; PROCEDURE Index ( Stream : T ) : Word . T  
  (* Number of Unicode characters that have been read from Stream.
     (Not fixed-sized code units.)  May overflow by wrapping. *) 

; PROCEDURE AvgBytesPerChar ( Stream : T ) : CARDINAL 
  (* Average number of encoded bytes per character, of what has been read. 
     Zero if nothing read. *) 

; PROCEDURE Length ( Stream : T ) : INTEGER RAISES { Failure , Alerted }
  (* Try to return the length of Stream, in Unicode characters (not code-units.)
     If Stream is closed or intermittent, or there is otherwise insufficient
     information, return -1.  If Stream has a fixed-size encoding, a 
     nonnegative value will be exact.  Otherwise, it will be an estimate.
  *)  

; PROCEDURE Intermittent( Stream : T ) : BOOLEAN RAISES {}
; PROCEDURE Seekable( Stream : T ) : BOOLEAN RAISES {}
; PROCEDURE Closed( Stream : T ) : BOOLEAN RAISES {}
(* Convenience wrappers for Intermittent(Stream.Source), etc.  
   respectively.  These can be applied to closed readers. *)

; END UniRd 
. 

