(* Copyright 1997-2003 John D. Polstra.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. All advertising materials mentioning features or use of this software
 *    must display the following acknowledgment:
 *      This product includes software developed by John D. Polstra.
 * 4. The name of the author may not be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *)

UNSAFE MODULE FileAttr EXPORTS FileAttr, FileAttrRep;

IMPORT
  CText, Ctypes, DevT, File, FilePosix, Fmt, IntTextTbl, M3toC,
  OSError, OSErrorPosix, Pathname, SupMisc, Text, TextIntTbl, Time,
  TokScan, Uerror, Ugrp, Unix, UnixMisc, Upwd, Ustat, Utypes,
  Word, Long;
FROM Utypes IMPORT nlink_t, off_t;

REVEAL
  T = Rep BRANDED OBJECT
  OVERRIDES
    init := Init;
  END;

CONST
  MaskRadix      = 16;
  FileTypeRadix  = 10;
  ModTimeRadix   = 10;
  SizeRadix      = 10;
  ModeRadix      =  8;
  FlagsRadix     = 16;
  LinkCountRadix = 10;
  InodeRadix     = 10;

  (* Pieces of Ustat.st_mode. *)
  PermMask  = 8_0777;  (* Access permissions. *)
  SetIDMask = 8_7000;  (* Setuid, setgid, and sticky bits. *)

VAR (* CONST *)
  EnoentAtom := OSErrorPosix.ErrnoAtom(Uerror.ENOENT);
CONST NoGroup: Utypes.gid_t = -1;
CONST NoOwner: Utypes.uid_t = -1;

PROCEDURE Init(self: T;
               fileType: FileType;
	       mode := -1;
	       modTime := -1.0d0;
	       size := LAST(CARDINAL)): T =
  BEGIN
    self.fileType := fileType;
    IF fileType # FileType.Unknown THEN
      self.mask := self.mask + AttrTypes{AttrType.FileType};
    END;
    IF mode # -1 THEN
      self.stat.st_mode := Word.And(mode, PermMask);
      self.mask := self.mask + AttrTypes{AttrType.Mode};
    END;
    IF modTime >= 0.0d0 THEN
      self.stat.st_mtime := VAL(ROUND(modTime), LONGINT);
      self.mask := self.mask + AttrTypes{AttrType.ModTime};
    END;
    IF size # LAST(CARDINAL) THEN
      self.stat.st_size := VAL(size, off_t);
      self.mask := self.mask + AttrTypes{AttrType.Size};
    END;
    (* If the LinkCount attribute is supported for this file type,
       set it to 1. *)
    IF AttrType.LinkCount IN Supported[fileType] THEN
      self.stat.st_nlink := VAL(1, nlink_t);
      self.mask := self.mask + AttrTypes{AttrType.LinkCount};
    END;
    RETURN self;
  END Init;

PROCEDURE Decode(t: TEXT): T
  RAISES {TokScan.Error, UnknownGroup, UnknownOwner} =
  VAR
    fa := NEW(T);
    pos: CARDINAL := 0;
    modeMask: Word.T;
    uid: Utypes.uid_t;
    gid: Utypes.gid_t;
  BEGIN
    fa.mask := ScanAttrTypes(t, pos);
    IF AttrType.FileType IN fa.mask THEN
      WITH val = ScanInt(t, pos, FileTypeRadix, "file type") DO
	IF val <= ORD(LAST(FileType)) THEN
	  fa.fileType := VAL(val, FileType);  (* Else leave it as unknown. *)
	END;
      END;
    ELSE
      fa.mask := fa.mask + AttrTypes{AttrType.FileType};  (* Always valid. *)
    END;
    fa.mask := fa.mask * Supported[fa.fileType];
    IF AttrType.ModTime IN fa.mask THEN
      fa.stat.st_mtime := ScanLong(t, pos, ModTimeRadix, "modTime");
    END;
    IF AttrType.Size IN fa.mask THEN
      fa.stat.st_size := ScanLong(t, pos, SizeRadix, "size");
    END;
    IF AttrType.LinkTarget IN fa.mask THEN
      fa.linkTarget := ScanText(t, pos);
    END;
    IF AttrType.RDev IN fa.mask THEN
      fa.stat.st_rdev := DevT.Decode(ScanText(t, pos));
    END;
    IF AttrType.Owner IN fa.mask THEN
      IF DecodeOwner(ScanText(t, pos), uid) THEN
	fa.stat.st_uid := uid;
      ELSE
	fa.mask := fa.mask - AttrTypes{AttrType.Owner};
      END;
    END;
    IF AttrType.Group IN fa.mask THEN
      IF DecodeGroup(ScanText(t, pos), gid) THEN
	fa.stat.st_gid := gid;
      ELSE
	fa.mask := fa.mask - AttrTypes{AttrType.Group};
      END;
    END;
    IF AttrType.Mode IN fa.mask THEN
      IF AttrType.Owner IN fa.mask AND AttrType.Group IN fa.mask THEN
	modeMask := Word.Or(SetIDMask, PermMask);
      ELSE
	modeMask := PermMask;
      END;
      fa.stat.st_mode :=
	Word.And(ScanInt(t, pos, ModeRadix, "mode"), modeMask);
    END;
    IF AttrType.Flags IN fa.mask THEN
      SetFlags(fa, ScanInt(t, pos, FlagsRadix, "flags"));
    END;
    IF AttrType.LinkCount IN fa.mask THEN
      fa.stat.st_nlink := ScanLong(t, pos, LinkCountRadix, "linkCount");
    ELSE
      (* If the link count is missing but supported, fake it as 1. *)
      IF AttrType.LinkCount IN Supported[fa.fileType] THEN
	fa.stat.st_nlink := VAL(1, nlink_t);
	fa.mask := fa.mask + AttrTypes{AttrType.LinkCount};
      END;
    END;
    IF AttrType.Dev IN fa.mask THEN
      fa.stat.st_dev := DevT.Decode(ScanText(t, pos));
    END;
    IF AttrType.Inode IN fa.mask THEN
      fa.stat.st_ino := ScanLong(t, pos, InodeRadix, "inode");
    END;
    RETURN fa;
  END Decode;

PROCEDURE Encode(fa: T;
                 READONLY support := AllSupport;
		 ignore := AttrTypes{}): TEXT =
  VAR
    pieces: ARRAY [0 .. 3*NUMBER(AttrType) + 10] OF TEXT;
    nextPiece: CARDINAL;
    nPieces: CARDINAL;
    mask := fa.mask * support[fa.fileType] - ignore;
    name: TEXT;
    modeMask: Word.T;
  BEGIN
    nextPiece := 3;  (* Leave room at the beginning for the mask. *)
    IF AttrType.FileType IN mask THEN
      EncodeCounted(Fmt.Unsigned(ORD(fa.fileType), FileTypeRadix),
	pieces, nextPiece);
    END;
    IF AttrType.ModTime IN mask THEN
      EncodeCounted(Fmt.LongUnsigned(fa.stat.st_mtime, ModTimeRadix),
	pieces, nextPiece);
    END;
    IF AttrType.Size IN mask THEN
      EncodeCounted(Fmt.LongUnsigned(fa.stat.st_size, SizeRadix),
	pieces, nextPiece);
    END;
    IF AttrType.LinkTarget IN mask THEN
      EncodeCounted(fa.linkTarget, pieces, nextPiece);
    END;
    IF AttrType.RDev IN mask THEN
      EncodeCounted(DevT.Encode(fa.stat.st_rdev), pieces, nextPiece);
    END;
    IF AttrType.Owner IN mask THEN
      IF EncodeOwner(fa.stat.st_uid, name) THEN
	EncodeCounted(name, pieces, nextPiece);
      ELSE
	mask := mask - AttrTypes{AttrType.Owner};
      END;
    END;
    IF AttrType.Group IN mask THEN
      IF EncodeGroup(fa.stat.st_gid, name) THEN
	EncodeCounted(name, pieces, nextPiece);
      ELSE
	mask := mask - AttrTypes{AttrType.Group};
      END;
    END;
    IF AttrType.Mode IN mask THEN
      IF AttrType.Owner IN mask AND AttrType.Group IN mask THEN
	modeMask := Word.Or(SetIDMask, PermMask);
      ELSE
	modeMask := PermMask;
      END;
      WITH perms = Word.And(fa.stat.st_mode, modeMask) DO
	EncodeCounted(Fmt.Unsigned(perms, ModeRadix), pieces, nextPiece);
      END;
    END;
    IF AttrType.Flags IN mask THEN
      EncodeCounted(Fmt.Unsigned(GetFlags(fa), FlagsRadix), pieces, nextPiece);
    END;
    IF AttrType.LinkCount IN mask THEN
      (* As an optimization, we omit the link count if it is 1, and
	 reconstruct it again at Decode time.  This also helps us to
	 deal properly with older checkouts files that didn't contain
	 the link count. *)
      IF fa.stat.st_nlink = VAL(1, nlink_t) THEN
	mask := mask - AttrTypes{AttrType.LinkCount};
      ELSE
	EncodeCounted(Fmt.LongUnsigned(fa.stat.st_nlink, LinkCountRadix),
	  pieces, nextPiece);
      END;
    END;
    IF AttrType.Dev IN mask THEN
      EncodeCounted(DevT.Encode(fa.stat.st_dev), pieces, nextPiece);
    END;
    IF AttrType.Inode IN mask THEN
      EncodeCounted(Fmt.LongUnsigned(fa.stat.st_ino, InodeRadix),
        pieces, nextPiece);
    END;
    nPieces := nextPiece;
    nextPiece := 0;
    EncodeCounted(EncodeAttrTypes(mask), pieces, nextPiece);
    RETURN SupMisc.CatN(SUBARRAY(pieces, 0, nPieces));
  END Encode;

PROCEDURE EncodeCounted(t: TEXT;
                        VAR pieces: ARRAY OF TEXT;
			VAR nextPiece: CARDINAL) =
(* I'd like this to be a nested procedure inside "Encode", but that
   confuses the profiler.  So I leave it outside for now. *)
  BEGIN
    pieces[nextPiece] := Fmt.Int(Text.Length(t));
    INC(nextPiece);
    pieces[nextPiece] := "#";
    INC(nextPiece);
    pieces[nextPiece] := t;
    INC(nextPiece);
  END EncodeCounted;

PROCEDURE ScanAttrTypes(t: TEXT;
                        VAR pos: CARDINAL): AttrTypes
  RAISES {TokScan.Error} =
  VAR
    attrTypes := AttrTypes{};
  BEGIN
    TRY
      WITH flags = ScanInt(t, pos, MaskRadix, "AttrTypes") DO
	FOR attrType := FIRST(AttrType) TO LAST(AttrType) DO
	  IF Word.And(flags, Word.LeftShift(1, ORD(attrType))) # 0 THEN
	    attrTypes := attrTypes + AttrTypes{attrType};
	  END;
	END;
      END;
      RETURN attrTypes;
    EXCEPT TokScan.Error =>
      RAISE TokScan.Error("Invalid FileAttr.AttrTypes encoding");
    END;
  END ScanAttrTypes;

PROCEDURE ScanText(t: TEXT; VAR pos: CARDINAL): TEXT
  RAISES {TokScan.Error} =
  VAR
    tLen := Text.Length(t);
    count: INTEGER;
    at: TEXT;
  BEGIN
    count := TokScan.ScanLeadingInt(t, pos);
    IF pos >= tLen OR Text.GetChar(t, pos) # '#' THEN
      RAISE TokScan.Error("Missing \"#\"");
    END;
    INC(pos);
    at := Text.Sub(t, pos, count);
    INC(pos, count);
    IF pos > tLen THEN
      RAISE TokScan.Error("Short counted file attribute");
    END;
    RETURN at;
  END ScanText;

PROCEDURE ScanInt(t: TEXT;
                  VAR pos: CARDINAL;
                  radix: [2..16] := 10;
                  what: TEXT := "counted integer"): Word.T
  RAISES {TokScan.Error} =
  VAR
    tLen := Text.Length(t);
    count, val: Word.T := 0;
    ch: CHAR;
    digit: INTEGER;
  BEGIN
    WHILE pos < tLen DO
      ch := Text.GetChar(t, pos);
      INC(pos);
      IF ch < '0' OR ch > '9' THEN EXIT END;
      count := Word.Plus(Word.Times(count, 10), ORD(ch) - ORD('0'));
    END;
    IF pos >= tLen OR ch # '#' THEN
      RAISE TokScan.Error("Missing \"#\" in " & what);
    END;
    IF pos + count > tLen THEN
      RAISE TokScan.Error("Short counted file attribute");
    END;
    FOR i := 1 TO count DO
      ch := Text.GetChar(t, pos);
      INC(pos);
      CASE ch OF
      | '0'..'9' => digit := ORD(ch) - ORD('0');
      | 'a'..'f' => digit := ORD(ch) - ORD('a') + 10;
      | 'A'..'F' => digit := ORD(ch) - ORD('A') + 10;
      ELSE
	digit := radix;
      END;
      IF digit >= radix THEN
	RAISE TokScan.Error("Invalid " & what);
      END;
      val := Word.Plus(Word.Times(val, radix), digit);
    END;
    RETURN val;
  END ScanInt;

PROCEDURE ScanLong(t: TEXT;
                  VAR pos: CARDINAL;
                  radix: [2..16] := 10;
                  what: TEXT := "counted integer"): Long.T
  RAISES {TokScan.Error} =
  VAR
    tLen := Text.Length(t);
    count: Word.T := 0;
    val: Long.T := 0L;
    ch: CHAR;
    digit: INTEGER;
  BEGIN
    WHILE pos < tLen DO
      ch := Text.GetChar(t, pos);
      INC(pos);
      IF ch < '0' OR ch > '9' THEN EXIT END;
      count := Word.Plus(Word.Times(count, 10), ORD(ch) - ORD('0'));
    END;
    IF pos >= tLen OR ch # '#' THEN
      RAISE TokScan.Error("Missing \"#\" in " & what);
    END;
    IF pos + count > tLen THEN
      RAISE TokScan.Error("Short counted file attribute");
    END;
    FOR i := 1 TO count DO
      ch := Text.GetChar(t, pos);
      INC(pos);
      CASE ch OF
      | '0'..'9' => digit := ORD(ch) - ORD('0');
      | 'a'..'f' => digit := ORD(ch) - ORD('a') + 10;
      | 'A'..'F' => digit := ORD(ch) - ORD('A') + 10;
      ELSE
	digit := radix;
      END;
      IF digit >= radix THEN
	RAISE TokScan.Error("Invalid " & what);
      END;
      val := Long.Plus(Long.Times(val, VAL(radix, LONGINT)), VAL(digit, LONGINT));
    END;
    RETURN val;
  END ScanLong;

PROCEDURE IsSupported(fa: T; READONLY support: SupportInfo): BOOLEAN =
  BEGIN
    RETURN AttrType.FileType IN support[fa.fileType];
  END IsSupported;

PROCEDURE Equal(a, b: T): BOOLEAN =
  VAR
    mask := a.mask * b.mask;
    modeMask: Word.T;
  BEGIN
    modeMask := PermMask;
    IF AttrType.Owner IN mask AND AttrType.Group IN mask THEN
      modeMask := Word.Or(SetIDMask, modeMask);
    END;
    RETURN NOT (a.fileType = FileType.Unknown OR b.fileType = FileType.Unknown
      OR a.fileType # b.fileType
      OR AttrType.ModTime IN mask AND a.stat.st_mtime # b.stat.st_mtime
      OR AttrType.Size IN mask AND a.stat.st_size # b.stat.st_size
      OR AttrType.LinkTarget IN mask AND
	NOT Text.Equal(a.linkTarget, b.linkTarget)
      OR AttrType.RDev IN mask AND
	NOT DevT.Equal(a.stat.st_rdev, b.stat.st_rdev)
      OR AttrType.Owner IN mask AND a.stat.st_uid # b.stat.st_uid
      OR AttrType.Group IN mask AND a.stat.st_gid # b.stat.st_gid
      OR AttrType.Mode IN mask AND
	Word.And(a.stat.st_mode, modeMask) # Word.And(b.stat.st_mode, modeMask)
      OR AttrType.Flags IN mask AND GetFlags(a) # GetFlags(b)
      OR AttrType.LinkCount IN mask AND a.stat.st_nlink # b.stat.st_nlink
      OR AttrType.Dev IN mask AND
	NOT DevT.Equal(a.stat.st_dev, b.stat.st_dev)
      OR AttrType.Inode IN mask AND a.stat.st_ino # b.stat.st_ino);
  END Equal;

PROCEDURE Clone(fa: T): T =
  BEGIN
    RETURN NEW(T,
      fileType := fa.fileType,
      mask := fa.mask,
      stat := fa.stat,
      linkTarget := fa.linkTarget);
  END Clone;

PROCEDURE Merge(fa, from: T): T =
  BEGIN
    RETURN Override(fa, from, from.mask - fa.mask);
  END Merge;

PROCEDURE MergeDefault(fa: T): T =
  BEGIN
    RETURN Merge(fa, Default[fa.fileType]);
  END MergeDefault;

PROCEDURE Override(fa, from: T; mask := AllAttrTypes): T =
  CONST
    OGM = AttrTypes{AttrType.Owner, AttrType.Group, AttrType.Mode};
  BEGIN
    fa := Clone(fa);
    mask := mask * from.mask;
    fa.mask := fa.mask + mask;
    IF AttrType.FileType IN mask THEN
      fa.fileType := from.fileType;
    END;
    IF AttrType.ModTime IN mask THEN
      fa.stat.st_mtime := from.stat.st_mtime;
    END;
    IF AttrType.Size IN mask THEN
      fa.stat.st_size := from.stat.st_size;
    END;
    IF AttrType.LinkTarget IN mask THEN
      fa.linkTarget := from.linkTarget;
    END;
    IF AttrType.RDev IN mask THEN
      fa.stat.st_rdev := from.stat.st_rdev;
    END;
    IF AttrType.Owner IN mask THEN
      fa.stat.st_uid := from.stat.st_uid;
    END;
    IF AttrType.Group IN mask THEN
      fa.stat.st_gid := from.stat.st_gid;
    END;
    IF AttrType.Mode IN mask THEN
      fa.stat.st_mode := from.stat.st_mode;
    END;
    IF AttrType.Flags IN mask THEN
      SetFlags(fa, GetFlags(from));
    END;
    IF AttrType.LinkCount IN mask THEN
      fa.stat.st_nlink := from.stat.st_nlink;
    END;
    IF AttrType.Dev IN mask THEN
      fa.stat.st_dev := from.stat.st_dev;
    END;
    IF AttrType.Inode IN mask THEN
      fa.stat.st_ino := from.stat.st_ino;
    END;

    (* If the owner, group, and mode aren't all from the same source,
       clear the setid bits. *)
    mask := mask * OGM;
    IF mask # OGM AND mask # AttrTypes{} THEN
      fa.stat.st_mode := Word.And(fa.stat.st_mode, PermMask);
    END;

    RETURN fa;
  END Override;

PROCEDURE Umask(fa: T; umask := -1): T =
  BEGIN
    IF AttrType.Mode IN fa.mask THEN
      WITH newMode = UnixMisc.MaskMode(fa.stat.st_mode, umask) DO
	IF newMode # fa.stat.st_mode THEN
	  fa := Clone(fa);
	  fa.stat.st_mode := newMode;
	END;
      END;
    END;
    RETURN fa;
  END Umask;

PROCEDURE MaskOut(fa: T; mask: AttrTypes): T =
  VAR
    newMask := fa.mask - mask;
  BEGIN
    IF newMask # fa.mask THEN  (* We actually removed something. *)
      fa := Clone(fa);
      fa.mask := newMask;
    END;
    RETURN fa;
  END MaskOut;

PROCEDURE DecodeAttrTypes(text: TEXT): AttrTypes
  RAISES {TokScan.Error} =
  VAR
    attrTypes := AttrTypes{};
  BEGIN
    TRY
      WITH flags = TokScan.AtoI(text, "AttrTypes", MaskRadix) DO
	FOR attrType := FIRST(AttrType) TO LAST(AttrType) DO
	  IF Word.And(flags, Word.LeftShift(1, ORD(attrType))) # 0 THEN
	    attrTypes := attrTypes + AttrTypes{attrType};
	  END;
	END;
      END;
      RETURN attrTypes;
    EXCEPT TokScan.Error =>
      RAISE TokScan.Error("Invalid FileAttr.AttrTypes encoding");
    END;
  END DecodeAttrTypes;

PROCEDURE EncodeAttrTypes(attrTypes: AttrTypes): TEXT =
  VAR
    flags: Word.T := 0;
  BEGIN
    FOR attrType := FIRST(AttrType) TO LAST(AttrType) DO
      IF attrType IN attrTypes THEN
	flags := Word.Or(flags, Word.LeftShift(1, ORD(attrType)));
      END;
    END;
    RETURN Fmt.Unsigned(flags, MaskRadix);
  END EncodeAttrTypes;

PROCEDURE FromFD(fd: INTEGER): T
  RAISES {OSError.E} =
  VAR
    stat: Ustat.struct_stat;
  BEGIN
    IF Ustat.fstat(fd, ADR(stat)) = -1 THEN
      OSErrorPosix.Raise();
    END;
    (* The file cannot be a symbolic link, because we have an open
       descriptor for it. *)
    RETURN FromStat(stat);
  END FromFD;

PROCEDURE FromFile(file: File.T): T
  RAISES {OSError.E} =
  BEGIN
    RETURN FromFD(file.fd);
  END FromFile;

PROCEDURE FromPathname(path: Pathname.T; follow: BOOLEAN): T
  RAISES {OSError.E} =
  VAR
    stat: Ustat.struct_stat;
    ret: INTEGER;
    fa: T;
  BEGIN
    WITH s = CText.SharedTtoS(path) DO
      IF follow THEN
	ret := Ustat.stat(s, ADR(stat));
      ELSE
	ret := Ustat.lstat(s, ADR(stat));
      END;
      CText.FreeSharedS(path, s);
    END;
    IF ret = -1 THEN
      OSErrorPosix.Raise();
    END;
    fa := FromStat(stat);
    IF AttrType.LinkTarget IN fa.mask THEN
      fa.linkTarget := UnixMisc.ReadLink(path);
    END;
    RETURN fa;
  END FromPathname;

PROCEDURE FromStat(READONLY stat: Ustat.struct_stat): T =
  VAR
    fa := NEW(T, stat := stat);
    type: INTEGER;
  BEGIN
    type := Word.And(fa.stat.st_mode, Ustat.S_IFMT);
    IF type = Ustat.S_IFREG THEN
      fa.fileType := FileType.File;
    ELSIF type = Ustat.S_IFDIR THEN
      fa.fileType := FileType.Directory;
    ELSIF type = Ustat.S_IFCHR THEN
      fa.fileType := FileType.CharDevice;
    ELSIF type = Ustat.S_IFBLK THEN
      fa.fileType := FileType.BlockDevice;
    ELSIF type = Ustat.S_IFLNK THEN
      fa.fileType := FileType.SymLink;
    ELSE
      fa.fileType := FileType.Unknown;
    END;
    fa.mask := AttrTypes{AttrType.FileType} + Supported[fa.fileType];
    RETURN fa;
  END FromStat;

PROCEDURE ForCheckout(rcsAttr: T; umask := -1): T =
  VAR
    fileMode: Utypes.mode_t;
  BEGIN
    IF AttrType.Mode IN rcsAttr.mask THEN
      IF Word.And(GetMode(rcsAttr), 8_111) # 0 THEN
	fileMode := 8_777;
      ELSE
	fileMode := 8_666;
      END;
      fileMode := UnixMisc.MaskMode(fileMode, umask);
      RETURN NEW(T).init(FileType.File, mode := fileMode);
    ELSE
      RETURN NEW(T).init(FileType.File);
    END;
  END ForCheckout;

PROCEDURE MakeNode(fa: T; path: Pathname.T)
  RAISES {OSError.E} =
  VAR
    pathStr, targetStr: Ctypes.char_star;
    linkTarget := fa.linkTarget;  (* On stack for SharedTtoS. *)
    status: INTEGER;
    mode: Utypes.mode_t;
    modeMask: Word.T;
  BEGIN
    IF AttrType.Owner IN fa.mask AND AttrType.Group IN fa.mask THEN
      modeMask := Word.Or(SetIDMask, PermMask);
    ELSE
      modeMask := PermMask;
    END;
    CASE fa.fileType OF
    | FileType.Unknown, FileType.File =>
	<* ASSERT FALSE *>
    | FileType.Directory =>
	IF AttrType.Mode IN fa.mask THEN
	  mode := Word.And(fa.stat.st_mode, modeMask);
	ELSE
	  mode := 8_700;
	END;
	pathStr := CText.SharedTtoS(path);
	status := Unix.mkdir(pathStr, mode);
	CText.FreeSharedS(path, pathStr);
    | FileType.CharDevice =>
	IF AttrType.Mode IN fa.mask THEN
	  mode := Word.And(fa.stat.st_mode, modeMask);
	ELSE
	  mode := 8_600;
	END;
	DevT.Mknod(path,
	  mode := Word.Or(Ustat.S_IFCHR, mode),
	  dev := fa.stat.st_rdev);
	status := 0;
    | FileType.BlockDevice =>
	IF AttrType.Mode IN fa.mask THEN
	  mode := Word.And(fa.stat.st_mode, modeMask);
	ELSE
	  mode := 8_600;
	END;
	DevT.Mknod(path,
	  mode := Word.Or(Ustat.S_IFBLK, mode),
	  dev := fa.stat.st_rdev);
	status := 0;
    | FileType.SymLink =>
	pathStr := CText.SharedTtoS(path);
	targetStr := CText.SharedTtoS(linkTarget);
	status := Unix.symlink(targetStr, pathStr);
	CText.FreeSharedS(linkTarget, targetStr);
	CText.FreeSharedS(path, pathStr);
    END;
    IF status = -1 THEN OSErrorPosix.Raise() END;
  END MakeNode;

PROCEDURE HardLink(path, target: Pathname.T): T
  RAISES {OSError.E} =
  VAR
    attr: T;
    oldFlags := 0;
    pathStr, targetStr: Ctypes.char_star;
    r: Ctypes.int;
  BEGIN
    attr := FromPathname(target, follow := FALSE);
    IF AttrType.Flags IN attr.mask THEN  (* Make sure the flags are cleared. *)
      oldFlags := GetFlags(attr);
      IF oldFlags # 0 THEN  (* Must clear the flags of the target. *)
	SetFlags(attr, 0);
	ChangeFileFlags(attr, target, follow := FALSE);
      END;
    END;

    pathStr := CText.SharedTtoS(path);
    targetStr := CText.SharedTtoS(target);
    r := Unix.link(targetStr, pathStr);
    CText.FreeSharedS(target, targetStr);
    CText.FreeSharedS(path, pathStr);
    IF r = -1 THEN OSErrorPosix.Raise() END;

    IF oldFlags # 0 THEN
      SetFlags(attr, oldFlags);
      attr.mask := AttrTypes{ AttrType.FileType, AttrType.Flags };
    ELSE
      attr.mask := AttrTypes{ AttrType.FileType };
    END;

    RETURN attr;
  END HardLink;

PROCEDURE Install(fa: T; to: Pathname.T; from: Pathname.T := NIL): BOOLEAN
  RAISES {OSError.E} =
(* This probably belongs in a more platform-dependent file, but we'll put
   it here for now. *)
  VAR
    toStr, fromStr: Ctypes.char_star;
    mask := fa.mask * Supported[fa.fileType];
    inPlace: BOOLEAN;
    oldAttr: T;
    status: INTEGER;
    modeMask: Word.T;
    newMode: Word.T;
  BEGIN
    IF AttrType.Owner IN mask AND AttrType.Group IN mask THEN
      modeMask := Word.Or(SetIDMask, PermMask);
    ELSE
      modeMask := PermMask;
    END;

    toStr := CText.SharedTtoS(to);
    IF from = NIL THEN  (* Changing attributes in place. *)
      from := to;
      fromStr := toStr;
    ELSE
      fromStr := CText.SharedTtoS(from);
    END;

    TRY
      inPlace := Text.Equal(from, to);

      TRY
	oldAttr := FromPathname(to, follow := FALSE);

	(* Determine whether anything needs to be done. *)
	IF inPlace AND Equal(fa, oldAttr) THEN  (* That was easy! *)
	  RETURN FALSE;
	END;

	(* Determine whether we need to clear the flags of the target.
	   FIXME - This is bogus, because it blithely assumes that a
	   flags value of 0 is safe, and that non-zero is unsafe. *)
	IF AttrType.Flags IN oldAttr.mask AND GetFlags(oldAttr) # 0 THEN
	  (* Clear the flags. *)
	  TRY
	    SetFlags(oldAttr, 0);
	    ChangeFileFlags(oldAttr, to, follow := FALSE);
	  EXCEPT OSError.E => (* Ignore. *) END;
	END;

	(* Determine whether we need to remove the target first. *)
	IF NOT inPlace AND (fa.fileType = FileType.Directory) #
	(oldAttr.fileType = FileType.Directory) THEN  (* Remove. *)
	  IF oldAttr.fileType = FileType.Directory THEN
	    EVAL Unix.rmdir(toStr);
	  ELSE
	    EVAL Unix.unlink(toStr);
	  END;
	END;
      EXCEPT OSError.E =>
	oldAttr := NIL;
      END;

      (* Change those attributes that we can before moving the file into
	 place.  That makes the installation atomic in most cases. *)
      IF AttrType.ModTime IN mask THEN
        SetModTime(fromStr, fa.stat.st_mtime);
      END;
      IF AttrType.Owner IN mask OR AttrType.Group IN mask THEN
	VAR
	  owner := NoOwner;
	  group := NoGroup;
	BEGIN
	  IF AttrType.Owner IN mask THEN owner := fa.stat.st_uid END;
	  IF AttrType.Group IN mask THEN group := fa.stat.st_gid END;
	  EVAL Unix.chown(fromStr, owner, group);
	END;
      END;
      IF AttrType.Mode IN mask THEN
	newMode := Word.And(fa.stat.st_mode, modeMask);
	IF oldAttr # NIL AND AttrType.Mode IN oldAttr.mask THEN
	  (* Merge in the set*id bits from the old attributes. *)
	  newMode := Word.Or(newMode,
	    Word.And(oldAttr.stat.st_mode, Word.Not(modeMask)));
	  newMode := Word.And(newMode, Word.Or(SetIDMask, PermMask));
	END;
	EVAL Unix.chmod(fromStr, newMode);
      END;

      IF NOT inPlace THEN  (* Move the file into place. *)
	status := Unix.rename(fromStr, toStr);
      ELSE  (* Make sure the file at least exists. *)
	VAR
	  stat: Ustat.struct_stat;
	BEGIN
	  status := Ustat.stat(toStr, ADR(stat));
	END;
      END;
      IF status = -1 THEN
	OSErrorPosix.Raise();
      END;

      IF AttrType.Flags IN mask THEN  (* Set the flags. *)
	TRY
	  ChangeFileFlags(fa, to, follow := FALSE);
	EXCEPT OSError.E => (* Ignore. *) END;
      END;

      RETURN TRUE;
    FINALLY
      CText.FreeSharedS(to, toStr);
      IF fromStr # toStr THEN
	CText.FreeSharedS(from, fromStr);
      END;
    END;
  END Install;

PROCEDURE Delete(path: Pathname.T)
  RAISES {OSError.E} =
  VAR
    fa: T;
    status: INTEGER;
  BEGIN
    TRY
      fa := FromPathname(path, follow := FALSE);
    EXCEPT OSError.E(l) =>
      IF l.head = EnoentAtom THEN  (* The file doesn't exist. *)
	RETURN;
      ELSE  (* Re-raise the exception. *)
	RAISE OSError.E(l);
      END;
    END;

    IF AttrType.Flags IN fa.mask AND GetFlags(fa) # 0 THEN  (* Clear flags. *)
      TRY
	SetFlags(fa, 0);
	ChangeFileFlags(fa, path, follow := FALSE);
      EXCEPT OSError.E => (* Ignore. *) END;
    END;

    WITH pathStr = CText.SharedTtoS(path) DO
      IF fa.fileType = FileType.Directory THEN
	status := Unix.rmdir(pathStr);
      ELSE
	status := Unix.unlink(pathStr);
      END;
      CText.FreeSharedS(path, pathStr);
    END;

    IF status = -1 THEN
      OSErrorPosix.Raise();
    END;
  END Delete;

PROCEDURE GetMask(fa: T): AttrTypes =
  BEGIN
    RETURN fa.mask;
  END GetMask;

PROCEDURE GetModTime(fa: T): Time.T =
  BEGIN
    <* ASSERT AttrType.ModTime IN fa.mask *>
    RETURN FLOAT(fa.stat.st_mtime, Time.T);
  END GetModTime;

PROCEDURE GetSize(fa: T): CARDINAL =
  BEGIN
    <* ASSERT AttrType.Size IN fa.mask *>
    RETURN VAL(fa.stat.st_size, CARDINAL);
  END GetSize;

PROCEDURE SetSize(fa: T; size: CARDINAL) =
  BEGIN
    <* ASSERT AttrType.Size IN fa.mask *>
    fa.stat.st_size := VAL(size, off_t);
  END SetSize;

PROCEDURE GetMode(fa: T): Word.T =
  VAR
    modeMask: Word.T;
  BEGIN
    <* ASSERT AttrType.Mode IN fa.mask *>
    IF AttrType.Owner IN fa.mask AND AttrType.Group IN fa.mask THEN
      modeMask := Word.Or(SetIDMask, PermMask);
    ELSE
      modeMask := PermMask;
    END;
    RETURN Word.And(fa.stat.st_mode, modeMask);
  END GetMode;

PROCEDURE GetLinkTarget(fa: T): Pathname.T =
  BEGIN
    <* ASSERT AttrType.LinkTarget IN fa.mask *>
    RETURN fa.linkTarget;
  END GetLinkTarget;

PROCEDURE GetLinkCount(fa: T): CARDINAL =
  BEGIN
    <* ASSERT AttrType.LinkCount IN fa.mask *>
    RETURN VAL(fa.stat.st_nlink, CARDINAL);
  END GetLinkCount;

(*****************************************************************************)
(* Encoding/decoding of owners and groups. *)
(*****************************************************************************)

CONST  (* Sentinals to indicate IDs and names already known to be unknown. *)
  UnknownID = -100;
  UnknownName: Text.T = NIL;

VAR
  uidToNameTbl := NEW(IntTextTbl.Default).init();
  nameToUidTbl := NEW(TextIntTbl.Default).init();
  uidLock := NEW(MUTEX);

  gidToNameTbl := NEW(IntTextTbl.Default).init();
  nameToGidTbl := NEW(TextIntTbl.Default).init();
  gidLock := NEW(MUTEX);

PROCEDURE DecodeOwner(name: TEXT; VAR uid: Utypes.uid_t): BOOLEAN
  RAISES {UnknownOwner} =
  VAR
    iuid: INTEGER;
    nameStr: Ctypes.char_star;
    pwd: Upwd.struct_passwd_star;
  BEGIN
    LOCK uidLock DO
      IF nameToUidTbl.get(name, iuid) THEN
	IF iuid = UnknownID THEN RETURN FALSE END;
	uid := iuid;
	RETURN TRUE;
      END;
      nameStr := CText.SharedTtoS(name);
      pwd := Upwd.getpwnam(nameStr);
      CText.FreeSharedS(name, nameStr);
      IF pwd = NIL THEN  (* First lookup of this unknown owner. *)
	EVAL nameToUidTbl.put(name, UnknownID);
	RAISE UnknownOwner(name);
      END;
      uid := pwd.pw_uid;
      EVAL nameToUidTbl.put(name, uid);
      EVAL uidToNameTbl.put(uid, name);
    END;
    RETURN TRUE;
  END DecodeOwner;

PROCEDURE EncodeOwner(uid: Utypes.uid_t; VAR name: TEXT): BOOLEAN =
  BEGIN
    LOCK uidLock DO
      VAR
	tName: TEXT;
      BEGIN
	IF uidToNameTbl.get(uid, tName) THEN
	  IF tName = UnknownName THEN RETURN FALSE END;
	  name := tName;
	  RETURN TRUE;
	END;
      END;
      WITH pwd = Upwd.getpwuid(uid) DO
	IF pwd = NIL THEN
	  EVAL uidToNameTbl.put(uid, UnknownName);
	  RETURN FALSE;
	END;
	name := M3toC.CopyStoT(pwd.pw_name);
      END;
      EVAL uidToNameTbl.put(uid, name);
      EVAL nameToUidTbl.put(name, uid);
    END;
    RETURN TRUE;
  END EncodeOwner;

PROCEDURE DecodeGroup(name: TEXT; VAR gid: Utypes.gid_t): BOOLEAN
  RAISES {UnknownGroup} =
  VAR
    igid: INTEGER;
    nameStr: Ctypes.char_star;
    group: Ugrp.struct_group;
    grp: Ugrp.struct_group_star;
  BEGIN
    LOCK gidLock DO
      IF nameToGidTbl.get(name, igid) THEN
	IF igid = UnknownID THEN RETURN FALSE END;
	gid := igid;
	RETURN TRUE;
      END;
      nameStr := CText.SharedTtoS(name);
      grp := Ugrp.getgrnam(ADR(group), nameStr);
      CText.FreeSharedS(name, nameStr);
      IF grp = NIL THEN  (* First lookup of this unknown group. *)
	EVAL nameToGidTbl.put(name, UnknownID);
	RAISE UnknownGroup(name);
      END;
      gid := grp.gr_gid;
      EVAL nameToGidTbl.put(name, gid);
      EVAL gidToNameTbl.put(gid, name);
    END;
    RETURN TRUE;
  END DecodeGroup;

PROCEDURE EncodeGroup(gid: Utypes.gid_t; VAR name: TEXT): BOOLEAN =
  VAR group: Ugrp.struct_group;  tName: TEXT;
  BEGIN
    LOCK gidLock DO
      BEGIN
	IF gidToNameTbl.get(gid, tName) THEN
	  IF tName = UnknownName THEN RETURN FALSE END;
	  name := tName;
	  RETURN TRUE;
	END;
      END;
      WITH grp = Ugrp.getgrgid(ADR(group), gid) DO
	IF grp = NIL THEN
	  EVAL gidToNameTbl.put(gid, UnknownName);
	  RETURN FALSE;
	END;
	name := M3toC.CopyStoT(grp.gr_name);
      END;
      EVAL gidToNameTbl.put(gid, name);
      EVAL nameToGidTbl.put(name, gid);
    END;
    RETURN TRUE;
  END EncodeGroup;

(*****************************************************************************)

BEGIN
  WITH nonDir = UnixMisc.MaskMode(8_666), dir = UnixMisc.MaskMode(8_777) DO
    FOR ft := FIRST(FileType) TO LAST(FileType) DO
      IF ft = FileType.Directory THEN
	Default[ft] := NEW(T).init(ft, mode := dir);
      ELSE
	Default[ft] := NEW(T).init(ft, mode := nonDir);
      END;
    END;
  END;

  Historical := SupportInfo{ AttrTypes{}, .. };
  Historical[FileType.File] := AttrTypes{
    AttrType.FileType, AttrType.ModTime, AttrType.Mode };

  Bogus := NEW(T).init(FileType.Unknown,
    mode := 0,
    modTime := 1.0d0,
    size := 0);
END FileAttr.
