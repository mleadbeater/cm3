(*******************************************************************************
 * This file was automatically generated by SWIG (http://www.swig.org).
 * Version 3.0.10
 *
 * Do not make changes to this file unless you know what you are doing--modify
 * the SWIG interface file instead.
*******************************************************************************)

INTERFACE QtFontComboBox;

FROM QtSize IMPORT QSize;
FROM QtFont IMPORT QFont;
FROM QtWidget IMPORT QWidget;


FROM QtComboBox IMPORT QComboBox;

TYPE
  T = QFontComboBox;
  FontFilters = INTEGER;



CONST                            (* Enum FontFilter *)
  AllFonts          = 0;
  ScalableFonts     = 1;
  NonScalableFonts  = 2;
  MonospacedFonts   = 4;
  ProportionalFonts = 8;

TYPE                             (* Enum FontFilter *)
  FontFilter = [0 .. 8];


TYPE
  QFontComboBox <: QFontComboBoxPublic;
  QFontComboBoxPublic = QComboBox BRANDED OBJECT
                        METHODS
                          init_0 (parent: QWidget; ): QFontComboBox;
                          init_1 (): QFontComboBox;
                          setFontFilters (filters: FontFilters; );
                          fontFilters    (): FontFilters;
                          currentFont    (): QFont;
                          sizeHint       (): QSize; (* virtual *)
                          setCurrentFont (f: QFont; );
                          destroyCxx     ();
                        END;


END QtFontComboBox.
