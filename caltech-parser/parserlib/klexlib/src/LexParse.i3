(* Copyright (c) 2000 California Institute of Technology *)
(* All rights reserved. See the file COPYRIGHT for a full description. *)
(* $Id: LexParse.i3,v 1.2 2001-09-19 15:04:09 wagner Exp $ *)

INTERFACE LexParse;
IMPORT NFA;
IMPORT Rd;
IMPORT TokSpec;
IMPORT TextList;
TYPE
  T <: Public;
  Public = OBJECT
    n: NFA.T;
    names: TextList.T;
  END;
PROCEDURE New(from: Rd.T; tok: TokSpec.T): T;
END LexParse.
