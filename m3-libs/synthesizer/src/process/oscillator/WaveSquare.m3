MODULE WaveSquare;

PROCEDURE Wave (x: LONGREAL; ): LONGREAL =
  BEGIN
    IF x < 0.5D0 THEN RETURN 1.0D0; ELSE RETURN -1.0D0; END;
  END Wave;

BEGIN
END WaveSquare.
