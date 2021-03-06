(* Copyright (c) 2000 California Institute of Technology *)
(* All rights reserved. See the file COPYRIGHT for a full description. *)
(* $Id: Override.i3,v 1.2 2001-09-19 15:14:22 wagner Exp $ *)

INTERFACE Override;
IMPORT TextTextTbl;
IMPORT Rd;
TYPE
  T <: Public;
  Public = OBJECT
  METHODS
    init(specs: TextTextTbl.T): T;
    add(name, body: TEXT; rd: Rd.T);
    importRemaining();
    getProcAssignText(): TEXT;
    getText(): TEXT;
    overridden(name: TEXT): BOOLEAN;
  END;
END Override.
    
