(* Copyright (c) 2000 California Institute of Technology *)
(* All rights reserved. See the file COPYRIGHT for a full description. *)
(* $Id: PaneManRequest.i3,v 1.2 2001-09-19 14:22:13 wagner Exp $ *)

INTERFACE PaneManRequest;
IMPORT PaneManOp;
IMPORT StarterScan;
TYPE
  Kind = {Start, Print, Input};
  T = RECORD
    kind: Kind;
    message: TEXT := NIL;
    default: TEXT := NIL;
    cb: PaneManOp.InputCallback := NIL;
    s: StarterScan.T := NIL;
  END;
END PaneManRequest.
