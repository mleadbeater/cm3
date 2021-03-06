(*******************************************************************************
 * This file was automatically generated by SWIG (http://www.swig.org).
 * Version 3.0.10
 *
 * Do not make changes to this file unless you know what you are doing--modify
 * the SWIG interface file instead.
*******************************************************************************)

INTERFACE QtRubberBand;

FROM QtSize IMPORT QSize;
FROM QtWidget IMPORT QWidget;
FROM QtPoint IMPORT QPoint;
FROM QtRect IMPORT QRect;


TYPE T = QRubberBand;


TYPE                             (* Enum Shape *)
  Shape = {Line, Rectangle};


TYPE
  QRubberBand <: QRubberBandPublic;
  QRubberBandPublic = QWidget BRANDED OBJECT
                      METHODS
                        init_0 (arg1: Shape; arg2: QWidget; ): QRubberBand;
                        init_1 (arg1: Shape; ): QRubberBand;
                        shape  (): Shape;
                        setGeometry  (r: QRect; );
                        setGeometry1 (x, y, w, h: INTEGER; );
                        move         (x, y: INTEGER; );
                        move1        (p: QPoint; );
                        resize       (w, h: INTEGER; );
                        resize1      (s: QSize; );
                        destroyCxx   ();
                      END;


END QtRubberBand.
