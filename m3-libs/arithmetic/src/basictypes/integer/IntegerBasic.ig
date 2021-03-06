GENERIC INTERFACE IntegerBasic(I, It);
(* Arithmetic for Modula-3, see doc for details *)

FROM Arithmetic IMPORT Error;

CONST Brand = It.Brand;

TYPE
  T = I.T;
  QuotRem = RECORD quot, rem: T END;
  Array = REF ARRAY OF T;

CONST
  Zero     = 0;
  One      = 1;
  Two      = 2;
  MinusOne = -1;

CONST
  Equal   = It.Equal;
  Compare = It.Compare;

<* INLINE *>
PROCEDURE Add (x, y: T; ): T;    (* x+y *)
<* INLINE *>
PROCEDURE Sub (x, y: T; ): T;    (* x-y *)
<* INLINE *>
PROCEDURE Neg (x: T; ): T;       (* -x *)
<* INLINE *>
PROCEDURE Conj (x: T; ): T;      (* x *)
<* INLINE *>
PROCEDURE IsZero (x: T; ): BOOLEAN;

<* INLINE *>
PROCEDURE Mul (x, y: T; ): T;    (* x*y *)
<* INLINE *>
PROCEDURE Div (x, y: T; ): T RAISES {Error}; (* x/y *)
<* INLINE *>
PROCEDURE Rec (x: T; ): T RAISES {Error}; (* 1/x *)
<* INLINE *>
PROCEDURE Mod (x, y: T; ): T RAISES {Error}; (* x mod y *)
<* INLINE *>
PROCEDURE DivMod (x, y: T; ): QuotRem RAISES {Error}; (* x/y and x mod y *)

PROCEDURE GCD (x, y: T; ): T;
(* greatest common divisor for machines with slow division *)

END IntegerBasic.
