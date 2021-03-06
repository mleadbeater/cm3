(*******************************************************************************
 * This file was automatically generated by SWIG (http://www.swig.org).
 * Version 3.0.10
 *
 * Do not make changes to this file unless you know what you are doing--modify
 * the SWIG interface file instead.
*******************************************************************************)

UNSAFE MODULE QtSizePolicy;


IMPORT QtSizePolicyRaw;
FROM QtNamespace IMPORT Orientations;


IMPORT WeakRef;

PROCEDURE New_QSizePolicy0 (self: QSizePolicy; ): QSizePolicy =
  VAR result: ADDRESS;
  BEGIN
    result := QtSizePolicyRaw.New_QSizePolicy0();

    self.cxxObj := result;
    EVAL WeakRef.FromRef(self, Cleanup_QSizePolicy);

    RETURN self;
  END New_QSizePolicy0;

PROCEDURE New_QSizePolicy1
  (self: QSizePolicy; horizontal, vertical: Policy; ): QSizePolicy =
  VAR result: ADDRESS;
  BEGIN
    result :=
      QtSizePolicyRaw.New_QSizePolicy1(ORD(horizontal), ORD(vertical));

    self.cxxObj := result;
    EVAL WeakRef.FromRef(self, Cleanup_QSizePolicy);

    RETURN self;
  END New_QSizePolicy1;

PROCEDURE New_QSizePolicy2
  (self: QSizePolicy; horizontal, vertical: Policy; type: ControlType; ):
  QSizePolicy =
  VAR result: ADDRESS;
  BEGIN
    result := QtSizePolicyRaw.New_QSizePolicy2(
                ORD(horizontal), ORD(vertical), ORD(type));

    self.cxxObj := result;
    EVAL WeakRef.FromRef(self, Cleanup_QSizePolicy);

    RETURN self;
  END New_QSizePolicy2;

PROCEDURE QSizePolicy_horizontalPolicy (self: QSizePolicy; ): Policy =
  VAR
    ret    : INTEGER;
    result : Policy;
    selfAdr: ADDRESS := LOOPHOLE(self.cxxObj, ADDRESS);
  BEGIN
    ret := QtSizePolicyRaw.QSizePolicy_horizontalPolicy(selfAdr);
    result := VAL(ret, Policy);
    RETURN result;
  END QSizePolicy_horizontalPolicy;

PROCEDURE QSizePolicy_verticalPolicy (self: QSizePolicy; ): Policy =
  VAR
    ret    : INTEGER;
    result : Policy;
    selfAdr: ADDRESS := LOOPHOLE(self.cxxObj, ADDRESS);
  BEGIN
    ret := QtSizePolicyRaw.QSizePolicy_verticalPolicy(selfAdr);
    result := VAL(ret, Policy);
    RETURN result;
  END QSizePolicy_verticalPolicy;

PROCEDURE QSizePolicy_controlType (self: QSizePolicy; ): ControlType =
  VAR
    ret    : INTEGER;
    result : ControlType;
    selfAdr: ADDRESS     := LOOPHOLE(self.cxxObj, ADDRESS);
  BEGIN
    ret := QtSizePolicyRaw.QSizePolicy_controlType(selfAdr);
    result := VAL(ret, ControlType);
    RETURN result;
  END QSizePolicy_controlType;

PROCEDURE QSizePolicy_setHorizontalPolicy
  (self: QSizePolicy; d: Policy; ) =
  VAR selfAdr: ADDRESS := LOOPHOLE(self.cxxObj, ADDRESS);
  BEGIN
    QtSizePolicyRaw.QSizePolicy_setHorizontalPolicy(selfAdr, ORD(d));
  END QSizePolicy_setHorizontalPolicy;

PROCEDURE QSizePolicy_setVerticalPolicy (self: QSizePolicy; d: Policy; ) =
  VAR selfAdr: ADDRESS := LOOPHOLE(self.cxxObj, ADDRESS);
  BEGIN
    QtSizePolicyRaw.QSizePolicy_setVerticalPolicy(selfAdr, ORD(d));
  END QSizePolicy_setVerticalPolicy;

PROCEDURE QSizePolicy_setControlType
  (self: QSizePolicy; type: ControlType; ) =
  VAR selfAdr: ADDRESS := LOOPHOLE(self.cxxObj, ADDRESS);
  BEGIN
    QtSizePolicyRaw.QSizePolicy_setControlType(selfAdr, ORD(type));
  END QSizePolicy_setControlType;

PROCEDURE QSizePolicy_expandingDirections (self: QSizePolicy; ):
  Orientations =
  VAR
    ret    : INTEGER;
    result : Orientations;
    selfAdr: ADDRESS      := LOOPHOLE(self.cxxObj, ADDRESS);
  BEGIN
    ret := QtSizePolicyRaw.QSizePolicy_expandingDirections(selfAdr);
    result := VAL(ret, Orientations);
    RETURN result;
  END QSizePolicy_expandingDirections;

PROCEDURE QSizePolicy_setHeightForWidth (self: QSizePolicy; b: BOOLEAN; ) =
  VAR selfAdr: ADDRESS := LOOPHOLE(self.cxxObj, ADDRESS);
  BEGIN
    QtSizePolicyRaw.QSizePolicy_setHeightForWidth(selfAdr, b);
  END QSizePolicy_setHeightForWidth;

PROCEDURE QSizePolicy_hasHeightForWidth (self: QSizePolicy; ): BOOLEAN =
  VAR selfAdr: ADDRESS := LOOPHOLE(self.cxxObj, ADDRESS);
  BEGIN
    RETURN QtSizePolicyRaw.QSizePolicy_hasHeightForWidth(selfAdr);
  END QSizePolicy_hasHeightForWidth;

PROCEDURE QSizePolicy_setWidthForHeight (self: QSizePolicy; b: BOOLEAN; ) =
  VAR selfAdr: ADDRESS := LOOPHOLE(self.cxxObj, ADDRESS);
  BEGIN
    QtSizePolicyRaw.QSizePolicy_setWidthForHeight(selfAdr, b);
  END QSizePolicy_setWidthForHeight;

PROCEDURE QSizePolicy_hasWidthForHeight (self: QSizePolicy; ): BOOLEAN =
  VAR selfAdr: ADDRESS := LOOPHOLE(self.cxxObj, ADDRESS);
  BEGIN
    RETURN QtSizePolicyRaw.QSizePolicy_hasWidthForHeight(selfAdr);
  END QSizePolicy_hasWidthForHeight;

PROCEDURE QSizePolicy_horizontalStretch (self: QSizePolicy; ): INTEGER =
  VAR selfAdr: ADDRESS := LOOPHOLE(self.cxxObj, ADDRESS);
  BEGIN
    RETURN QtSizePolicyRaw.QSizePolicy_horizontalStretch(selfAdr);
  END QSizePolicy_horizontalStretch;

PROCEDURE QSizePolicy_verticalStretch (self: QSizePolicy; ): INTEGER =
  VAR selfAdr: ADDRESS := LOOPHOLE(self.cxxObj, ADDRESS);
  BEGIN
    RETURN QtSizePolicyRaw.QSizePolicy_verticalStretch(selfAdr);
  END QSizePolicy_verticalStretch;

PROCEDURE QSizePolicy_setHorizontalStretch
  (self: QSizePolicy; stretchFactor: CHAR; ) =
  VAR selfAdr: ADDRESS := LOOPHOLE(self.cxxObj, ADDRESS);
  BEGIN
    QtSizePolicyRaw.QSizePolicy_setHorizontalStretch(
      selfAdr, ORD(stretchFactor));
  END QSizePolicy_setHorizontalStretch;

PROCEDURE QSizePolicy_setVerticalStretch
  (self: QSizePolicy; stretchFactor: CHAR; ) =
  VAR selfAdr: ADDRESS := LOOPHOLE(self.cxxObj, ADDRESS);
  BEGIN
    QtSizePolicyRaw.QSizePolicy_setVerticalStretch(
      selfAdr, ORD(stretchFactor));
  END QSizePolicy_setVerticalStretch;

PROCEDURE QSizePolicy_transpose (self: QSizePolicy; ) =
  VAR selfAdr: ADDRESS := LOOPHOLE(self.cxxObj, ADDRESS);
  BEGIN
    QtSizePolicyRaw.QSizePolicy_transpose(selfAdr);
  END QSizePolicy_transpose;

PROCEDURE Delete_QSizePolicy (self: QSizePolicy; ) =
  VAR selfAdr: ADDRESS := LOOPHOLE(self.cxxObj, ADDRESS);
  BEGIN
    QtSizePolicyRaw.Delete_QSizePolicy(selfAdr);
  END Delete_QSizePolicy;

PROCEDURE Cleanup_QSizePolicy
  (<* UNUSED *> READONLY self: WeakRef.T; ref: REFANY) =
  VAR obj: QSizePolicy := ref;
  BEGIN
    Delete_QSizePolicy(obj);
  END Cleanup_QSizePolicy;

PROCEDURE Destroy_QSizePolicy (self: QSizePolicy) =
  BEGIN
    EVAL WeakRef.FromRef(self, Cleanup_QSizePolicy);
  END Destroy_QSizePolicy;

REVEAL
  QSizePolicy = QSizePolicyPublic BRANDED OBJECT
                OVERRIDES
                  init_0               := New_QSizePolicy0;
                  init_1               := New_QSizePolicy1;
                  init_2               := New_QSizePolicy2;
                  horizontalPolicy     := QSizePolicy_horizontalPolicy;
                  verticalPolicy       := QSizePolicy_verticalPolicy;
                  controlType          := QSizePolicy_controlType;
                  setHorizontalPolicy  := QSizePolicy_setHorizontalPolicy;
                  setVerticalPolicy    := QSizePolicy_setVerticalPolicy;
                  setControlType       := QSizePolicy_setControlType;
                  expandingDirections  := QSizePolicy_expandingDirections;
                  setHeightForWidth    := QSizePolicy_setHeightForWidth;
                  hasHeightForWidth    := QSizePolicy_hasHeightForWidth;
                  setWidthForHeight    := QSizePolicy_setWidthForHeight;
                  hasWidthForHeight    := QSizePolicy_hasWidthForHeight;
                  horizontalStretch    := QSizePolicy_horizontalStretch;
                  verticalStretch      := QSizePolicy_verticalStretch;
                  setHorizontalStretch := QSizePolicy_setHorizontalStretch;
                  setVerticalStretch   := QSizePolicy_setVerticalStretch;
                  transpose            := QSizePolicy_transpose;
                  destroyCxx           := Destroy_QSizePolicy;
                END;


BEGIN
END QtSizePolicy.
