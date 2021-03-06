(*******************************************************************************
 * This file was automatically generated by SWIG (http://www.swig.org).
 * Version 3.0.10
 *
 * Do not make changes to this file unless you know what you are doing--modify
 * the SWIG interface file instead.
*******************************************************************************)

INTERFACE QtBitmap;

FROM QtImage IMPORT QImage, Format;
FROM QtSize IMPORT QSize;
FROM QtPixmap IMPORT QPixmap;
FROM QtMatrix IMPORT QMatrix;
FROM QtTransform IMPORT QTransform;
FROM QtNamespace IMPORT ImageConversionFlags;



TYPE T = QBitmap;

PROCEDURE FromBitmapImage (image: QImage; flags: ImageConversionFlags; ):
  QBitmap;

PROCEDURE FromBitmapImage1 (image: QImage; ): QBitmap;

PROCEDURE FromData (size: QSize; bits: ADDRESS; monoFormat: Format; ):
  QBitmap;

PROCEDURE FromData1 (size: QSize; bits: ADDRESS; ): QBitmap;


TYPE
  QBitmap <: QBitmapPublic;
  QBitmapPublic = QPixmap BRANDED OBJECT
                  METHODS
                    init_0       (): QBitmap;
                    init_1       (arg1: QPixmap; ): QBitmap;
                    init_2       (w, h: INTEGER; ): QBitmap;
                    init_3       (arg1: QSize; ): QBitmap;
                    init_4       (fileName, format: TEXT; ): QBitmap;
                    init_5       (fileName: TEXT; ): QBitmap;
                    swap         (other: QBitmap; );
                    clear        ();
                    transformed  (arg1: QMatrix; ): QBitmap;
                    transformed1 (matrix: QTransform; ): QBitmap;
                    destroyCxx   ();
                  END;


END QtBitmap.
