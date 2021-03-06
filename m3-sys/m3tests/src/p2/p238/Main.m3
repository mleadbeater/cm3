MODULE Main;
IMPORT IO;

TYPE Function = PROCEDURE ():INTEGER;

PROCEDURE A(k: INTEGER; x1, x2, x3, x4, x5: Function): INTEGER =

  PROCEDURE B(): INTEGER =
  BEGIN
    DEC(k);
    RETURN A(k, B, x1, x2, x3, x4);
  END B;

BEGIN
  IF k <= 0 THEN
    RETURN x4() + x5();
  ELSE
    RETURN B();
  END;
END A;

PROCEDURE F0(): INTEGER = BEGIN RETURN 0; END F0;
PROCEDURE F1(): INTEGER = BEGIN RETURN 1; END F1;
PROCEDURE Fn1(): INTEGER = BEGIN RETURN -1; END Fn1;

BEGIN
  IO.PutInt(A(10, F1, Fn1, Fn1, F1, F0));
  IO.Put("\n");
END Main.
