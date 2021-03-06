(*******************************************************************************
 * This file was automatically generated by SWIG (http://www.swig.org/).
 * Version: 1.3.22
 *
 * Do not make changes to this file unless you know what you are doing --
 * modify the SWIG interface file instead.
 *******************************************************************************)

UNSAFE MODULE ExtendedFFTW;

IMPORT ExtendedFFTWRaw;
IMPORT M3toC;
IMPORT Ctypes AS C;
IMPORT Cstdio;
IMPORT WeakRef;


IMPORT Extended AS R, ExtendedFFTWRaw AS Raw;


CONST dirToSign = ARRAY Dir OF [-1 .. 1]{-1, 1};

REVEAL Plan = BRANDED REF Raw.Plan;

PROCEDURE CleanupPlan (<* UNUSED *> READONLY w: WeakRef.T; r: REFANY) =
  BEGIN
    Raw.DestroyPlan(NARROW(r, Plan)^);
  END CleanupPlan;

PROCEDURE DFTR2C1D (READONLY x: ARRAY OF R.T;
                    flags := FlagSet{Flag.Estimate}; ):
  REF ARRAY OF Complex =
  VAR
    z := NEW(REF ARRAY OF Complex, NUMBER(x) DIV 2 + 1);
    plan := Raw.PlanDFTR2C1D(
              NUMBER(x), x[0], z[0], LOOPHOLE(flags, C.unsigned_int));
  BEGIN
    TRY Raw.Execute(plan); FINALLY Raw.DestroyPlan(plan); END;
    RETURN z;
  END DFTR2C1D;

PROCEDURE DFTC2R1D (READONLY x     : ARRAY OF Complex;
                             parity: [0 .. 1];
                    flags := FlagSet{Flag.Estimate}; ): REF ARRAY OF R.T =
  VAR
    z := NEW(REF ARRAY OF R.T, NUMBER(x) * 2 - 2 + parity);
    plan := Raw.PlanDFTC2R1D(
              NUMBER(z^), x[0], z[0], LOOPHOLE(flags, C.unsigned_int));
  BEGIN
    TRY Raw.Execute(plan); FINALLY Raw.DestroyPlan(plan); END;
    RETURN z;
  END DFTC2R1D;

PROCEDURE DFTC2C1D (READONLY x   : ARRAY OF Complex;
                             sign: Dir                := Dir.Backward;
                    flags := FlagSet{Flag.Estimate}; ):
  REF ARRAY OF Complex =
  VAR
    z := NEW(REF ARRAY OF Complex, NUMBER(x));
    plan := Raw.PlanDFT1D(NUMBER(x), x[0], z[0], dirToSign[sign],
                          LOOPHOLE(flags, C.unsigned_int));
  BEGIN
    TRY Raw.Execute(plan); FINALLY Raw.DestroyPlan(plan); END;
    RETURN z;
  END DFTC2C1D;


PROCEDURE Execute (p: Plan; ) =
  BEGIN
    ExtendedFFTWRaw.Execute(p^);
  END Execute;

PROCEDURE PlanDFT1D (in, out: REF ARRAY OF Complex;
                     sign   : Dir                    := Dir.Backward;
                     flags: FlagSet := FlagSet{Flag.Estimate}; ): Plan
  RAISES {SizeMismatch} =
  VAR
    plan := NEW(Plan);
    n    := NUMBER(in^);
  BEGIN
    IF n # NUMBER(out^) THEN RAISE SizeMismatch; END;
    plan^ := ExtendedFFTWRaw.PlanDFT1D(n, in[0], out[0], dirToSign[sign],
                                       LOOPHOLE(flags, C.unsigned_int));
    EVAL WeakRef.FromRef(plan, CleanupPlan);
    RETURN plan;
  END PlanDFT1D;

PROCEDURE PlanDFT2D (in, out: REF ARRAY OF ARRAY OF Complex;
                     sign : Dir     := Dir.Backward;
                     flags: FlagSet := FlagSet{Flag.Estimate}; ): Plan
  RAISES {SizeMismatch} =
  VAR
    plan := NEW(Plan);
    nx   := NUMBER(in^);
    ny   := NUMBER(in[0]);
  BEGIN
    IF nx # NUMBER(out^) OR ny # NUMBER(out[0]) THEN
      RAISE SizeMismatch;
    END;
    plan^ := ExtendedFFTWRaw.PlanDFT2D(
               nx, ny, in[0, 0], out[0, 0], dirToSign[sign],
               LOOPHOLE(flags, C.unsigned_int));
    EVAL WeakRef.FromRef(plan, CleanupPlan);
    RETURN plan;
  END PlanDFT2D;

PROCEDURE PlanDFT3D (in, out: REF ARRAY OF ARRAY OF ARRAY OF Complex;
                     sign : Dir     := Dir.Backward;
                     flags: FlagSet := FlagSet{Flag.Estimate}; ): Plan
  RAISES {SizeMismatch} =
  VAR
    plan := NEW(Plan);
    nx   := NUMBER(in^);
    ny   := NUMBER(in[0]);
    nz   := NUMBER(in[0, 0]);
  BEGIN
    IF nx # NUMBER(out^) OR ny # NUMBER(out[0]) OR nz # NUMBER(out[0, 0]) THEN
      RAISE SizeMismatch;
    END;
    plan^ := ExtendedFFTWRaw.PlanDFT3D(
               nx, ny, nz, in[0, 0, 0], out[0, 0, 0], dirToSign[sign],
               LOOPHOLE(flags, C.unsigned_int));
    EVAL WeakRef.FromRef(plan, CleanupPlan);
    RETURN plan;
  END PlanDFT3D;

PROCEDURE PlanDFTR2C1D (in : REF ARRAY OF R.T;
                        out: REF ARRAY OF Complex;
                        flags: FlagSet := FlagSet{Flag.Estimate}; ): Plan
  RAISES {SizeMismatch} =
  VAR
    plan := NEW(Plan);
    n    := NUMBER(in^) DIV 2 + 1;
  BEGIN
    IF n # NUMBER(out^) THEN RAISE SizeMismatch; END;
    plan^ := ExtendedFFTWRaw.PlanDFTR2C1D(
               n, in[0], out[0], LOOPHOLE(flags, C.unsigned_int));
    EVAL WeakRef.FromRef(plan, CleanupPlan);
    RETURN plan;
  END PlanDFTR2C1D;

PROCEDURE PlanDFTR2C2D (in : REF ARRAY OF ARRAY OF R.T;
                        out: REF ARRAY OF ARRAY OF Complex;
                        flags: FlagSet := FlagSet{Flag.Estimate}; ): Plan
  RAISES {SizeMismatch} =
  VAR
    plan := NEW(Plan);
    nx   := NUMBER(in^);
    ny   := NUMBER(in[0]) DIV 2 + 1;
  BEGIN
    IF nx # NUMBER(out^) OR ny # NUMBER(out[0]) THEN
      RAISE SizeMismatch;
    END;
    plan^ := ExtendedFFTWRaw.PlanDFTR2C2D(nx, ny, in[0, 0], out[0, 0],
                                          LOOPHOLE(flags, C.unsigned_int));
    EVAL WeakRef.FromRef(plan, CleanupPlan);
    RETURN plan;
  END PlanDFTR2C2D;

PROCEDURE PlanDFTR2C3D (in : REF ARRAY OF ARRAY OF ARRAY OF R.T;
                        out: REF ARRAY OF ARRAY OF ARRAY OF Complex;
                        flags: FlagSet := FlagSet{Flag.Estimate}; ): Plan
  RAISES {SizeMismatch} =
  VAR
    plan := NEW(Plan);
    nx   := NUMBER(in^);
    ny   := NUMBER(in[0]);
    nz   := NUMBER(in[0, 0]) DIV 2 + 1;
  BEGIN
    IF nx # NUMBER(out^) OR ny # NUMBER(out[0]) OR nz # NUMBER(out[0, 0]) THEN
      RAISE SizeMismatch;
    END;
    plan^ :=
      ExtendedFFTWRaw.PlanDFTR2C3D(nx, ny, nz, in[0, 0, 0], out[0, 0, 0],
                                   LOOPHOLE(flags, C.unsigned_int));
    EVAL WeakRef.FromRef(plan, CleanupPlan);
    RETURN plan;
  END PlanDFTR2C3D;

PROCEDURE PlanDFTC2R1D (in : REF ARRAY OF Complex;
                        out: REF ARRAY OF R.T;
                        flags: FlagSet := FlagSet{Flag.Estimate}; ): Plan
  RAISES {SizeMismatch} =
  VAR
    plan := NEW(Plan);
    n    := NUMBER(in^);
  BEGIN
    IF n # NUMBER(out^) DIV 2 + 1 THEN RAISE SizeMismatch; END;
    plan^ := ExtendedFFTWRaw.PlanDFTC2R1D(
               n, in[0], out[0], LOOPHOLE(flags, C.unsigned_int));
    EVAL WeakRef.FromRef(plan, CleanupPlan);
    RETURN plan;
  END PlanDFTC2R1D;

PROCEDURE PlanDFTC2R2D (in : REF ARRAY OF ARRAY OF Complex;
                        out: REF ARRAY OF ARRAY OF R.T;
                        flags: FlagSet := FlagSet{Flag.Estimate}; ): Plan
  RAISES {SizeMismatch} =
  VAR
    plan := NEW(Plan);
    nx   := NUMBER(in^);
    ny   := NUMBER(in[0]);
  BEGIN
    IF nx # NUMBER(out^) OR ny # NUMBER(out[0]) DIV 2 + 1 THEN
      RAISE SizeMismatch;
    END;
    plan^ := ExtendedFFTWRaw.PlanDFTC2R2D(nx, ny, in[0, 0], out[0, 0],
                                          LOOPHOLE(flags, C.unsigned_int));
    EVAL WeakRef.FromRef(plan, CleanupPlan);
    RETURN plan;
  END PlanDFTC2R2D;

PROCEDURE PlanDFTC2R3D (in : REF ARRAY OF ARRAY OF ARRAY OF Complex;
                        out: REF ARRAY OF ARRAY OF ARRAY OF R.T;
                        flags: FlagSet := FlagSet{Flag.Estimate}; ): Plan
  RAISES {SizeMismatch} =
  VAR
    plan := NEW(Plan);
    nx   := NUMBER(in^);
    ny   := NUMBER(in[0]);
    nz   := NUMBER(in[0, 0]);
  BEGIN
    IF nx # NUMBER(out^) OR ny # NUMBER(out[0])
         OR nz # NUMBER(out[0, 0]) DIV 2 + 1 THEN
      RAISE SizeMismatch;
    END;
    plan^ :=
      ExtendedFFTWRaw.PlanDFTC2R3D(nx, ny, nz, in[0, 0, 0], out[0, 0, 0],
                                   LOOPHOLE(flags, C.unsigned_int));
    EVAL WeakRef.FromRef(plan, CleanupPlan);
    RETURN plan;
  END PlanDFTC2R3D;

PROCEDURE PlanR2R1D (in, out: REF ARRAY OF R.T;
                     kind   : R2RKind;
                     flags: FlagSet := FlagSet{Flag.Estimate}; ): Plan
  RAISES {SizeMismatch} =
  VAR
    plan := NEW(Plan);
    n    := NUMBER(in^) DIV 2 + 1;
  BEGIN
    IF n # NUMBER(out^) DIV 2 + 1 THEN RAISE SizeMismatch; END;
    plan^ := ExtendedFFTWRaw.PlanR2R1D(n, in[0], out[0], ORD(kind),
                                       LOOPHOLE(flags, C.unsigned_int));
    EVAL WeakRef.FromRef(plan, CleanupPlan);
    RETURN plan;
  END PlanR2R1D;

PROCEDURE PlanR2R2D (in, out     : REF ARRAY OF ARRAY OF R.T;
                     kindx, kindy: R2RKind;
                     flags: FlagSet := FlagSet{Flag.Estimate}; ): Plan
  RAISES {SizeMismatch} =
  VAR
    plan := NEW(Plan);
    nx   := NUMBER(in^);
    ny   := NUMBER(in[0]) DIV 2 + 1;
  BEGIN
    IF nx # NUMBER(out^) OR ny # NUMBER(out[0]) DIV 2 + 1 THEN
      RAISE SizeMismatch;
    END;
    plan^ := ExtendedFFTWRaw.PlanR2R2D(
               nx, ny, in[0, 0], out[0, 0], ORD(kindx), ORD(kindy),
               LOOPHOLE(flags, C.unsigned_int));
    EVAL WeakRef.FromRef(plan, CleanupPlan);
    RETURN plan;
  END PlanR2R2D;

PROCEDURE PlanR2R3D (in, out: REF ARRAY OF ARRAY OF ARRAY OF R.T;
                     kindx, kindy, kindz: R2RKind;
                     flags: FlagSet := FlagSet{Flag.Estimate}; ): Plan
  RAISES {SizeMismatch} =
  VAR
    plan := NEW(Plan);
    nx   := NUMBER(in^);
    ny   := NUMBER(in[0]);
    nz   := NUMBER(in[0, 0]) DIV 2 + 1;
  BEGIN
    IF nx # NUMBER(out^) OR ny # NUMBER(out[0])
         OR nz # NUMBER(out[0, 0]) DIV 2 + 1 THEN
      RAISE SizeMismatch;
    END;
    plan^ := ExtendedFFTWRaw.PlanR2R3D(
               nx, ny, nz, in[0, 0, 0], out[0, 0, 0], ORD(kindx),
               ORD(kindy), ORD(kindz), LOOPHOLE(flags, C.unsigned_int));
    EVAL WeakRef.FromRef(plan, CleanupPlan);
    RETURN plan;
  END PlanR2R3D;

PROCEDURE DestroyPlan (p: Plan; ) =
  BEGIN
    ExtendedFFTWRaw.DestroyPlan(p^);
  END DestroyPlan;

PROCEDURE ForgetWisdom () =
  BEGIN
    ExtendedFFTWRaw.ForgetWisdom();
  END ForgetWisdom;

PROCEDURE Cleanup () =
  BEGIN
    ExtendedFFTWRaw.Cleanup();
  END Cleanup;

PROCEDURE ExportWisdomToFile (output_file: Cstdio.FILE_star; ) =
  BEGIN
    ExtendedFFTWRaw.ExportWisdomToFile(output_file);
  END ExportWisdomToFile;

PROCEDURE ExportWisdomToString (): TEXT =
  VAR result: C.char_star;
  BEGIN
    result := ExtendedFFTWRaw.ExportWisdomToString();
    RETURN M3toC.CopyStoT(result);
  END ExportWisdomToString;

PROCEDURE ExportWisdom (VAR write_char: PROCEDURE (c: CHAR; buf: ADDRESS; );
                        VAR data: REFANY; ) =
  BEGIN
    ExtendedFFTWRaw.ExportWisdom(write_char, LOOPHOLE(data, ADDRESS));
  END ExportWisdom;

PROCEDURE ImportSystemWisdom (): INTEGER =
  BEGIN
    RETURN ExtendedFFTWRaw.ImportSystemWisdom();
  END ImportSystemWisdom;

PROCEDURE ImportWisdomFromFile (input_file: Cstdio.FILE_star; ): INTEGER =
  BEGIN
    RETURN ExtendedFFTWRaw.ImportWisdomFromFile(input_file);
  END ImportWisdomFromFile;

PROCEDURE ImportWisdomFromString (input_string: TEXT; ): INTEGER =
  VAR
    arg1  : C.char_star;
    result: INTEGER;
  BEGIN
    arg1 := M3toC.SharedTtoS(input_string);
    result := ExtendedFFTWRaw.ImportWisdomFromString(arg1);
    M3toC.FreeSharedS(input_string, arg1);
    RETURN result;
  END ImportWisdomFromString;

PROCEDURE ImportWisdom (VAR read_char: PROCEDURE (buf: ADDRESS; ): CARDINAL;
                        VAR data: REFANY; ): INTEGER =
  BEGIN
    RETURN
      ExtendedFFTWRaw.ImportWisdom(read_char, LOOPHOLE(data, ADDRESS));
  END ImportWisdom;

PROCEDURE FPrintPlan (p: Plan; output_file: Cstdio.FILE_star; ) =
  BEGIN
    ExtendedFFTWRaw.FPrintPlan(p^, output_file);
  END FPrintPlan;

PROCEDURE PrintPlan (p: Plan; ) =
  BEGIN
    ExtendedFFTWRaw.PrintPlan(p^);
  END PrintPlan;

PROCEDURE Flops (p: Plan; VAR add, mul, fma: LONGREAL; ) =
  BEGIN
    ExtendedFFTWRaw.Flops(p^, add, mul, fma);
  END Flops;








BEGIN
END ExtendedFFTW.
