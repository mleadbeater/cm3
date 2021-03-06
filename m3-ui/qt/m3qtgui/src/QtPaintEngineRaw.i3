(*******************************************************************************
 * This file was automatically generated by SWIG (http://www.swig.org).
 * Version 3.0.10
 *
 * Do not make changes to this file unless you know what you are doing--modify
 * the SWIG interface file instead.
*******************************************************************************)

INTERFACE QtPaintEngineRaw;


IMPORT Ctypes AS C;




<* EXTERNAL QTextItem_descent *>
PROCEDURE QTextItem_descent (self: QTextItem; ): C.double;

<* EXTERNAL QTextItem_ascent *>
PROCEDURE QTextItem_ascent (self: QTextItem; ): C.double;

<* EXTERNAL QTextItem_width *>
PROCEDURE QTextItem_width (self: QTextItem; ): C.double;

<* EXTERNAL QTextItem_renderFlags *>
PROCEDURE QTextItem_renderFlags (self: QTextItem; ): C.int;

<* EXTERNAL QTextItem_text *>
PROCEDURE QTextItem_text (self: QTextItem; ): ADDRESS;

<* EXTERNAL QTextItem_font *>
PROCEDURE QTextItem_font (self: QTextItem; ): ADDRESS;

<* EXTERNAL Delete_QTextItem *>
PROCEDURE Delete_QTextItem (self: QTextItem; );

TYPE QTextItem <: ADDRESS;

<* EXTERNAL Delete_QPaintEngine *>
PROCEDURE Delete_QPaintEngine (self: QPaintEngine; );

<* EXTERNAL QPaintEngine_isActive *>
PROCEDURE QPaintEngine_isActive (self: QPaintEngine; ): BOOLEAN;

<* EXTERNAL QPaintEngine_setActive *>
PROCEDURE QPaintEngine_setActive (self: QPaintEngine; newState: BOOLEAN; );

<* EXTERNAL QPaintEngine_drawRects *>
PROCEDURE QPaintEngine_drawRects
  (self: QPaintEngine; rects: ADDRESS; rectCount: C.int; );

<* EXTERNAL QPaintEngine_drawRects1 *>
PROCEDURE QPaintEngine_drawRects1
  (self: QPaintEngine; rects: ADDRESS; rectCount: C.int; );

<* EXTERNAL QPaintEngine_drawLines *>
PROCEDURE QPaintEngine_drawLines
  (self: QPaintEngine; lines: ADDRESS; lineCount: C.int; );

<* EXTERNAL QPaintEngine_drawLines1 *>
PROCEDURE QPaintEngine_drawLines1
  (self: QPaintEngine; lines: ADDRESS; lineCount: C.int; );

<* EXTERNAL QPaintEngine_drawEllipse *>
PROCEDURE QPaintEngine_drawEllipse (self: QPaintEngine; r: ADDRESS; );

<* EXTERNAL QPaintEngine_drawEllipse1 *>
PROCEDURE QPaintEngine_drawEllipse1 (self: QPaintEngine; r: ADDRESS; );

<* EXTERNAL QPaintEngine_drawPoints *>
PROCEDURE QPaintEngine_drawPoints
  (self: QPaintEngine; points: ADDRESS; pointCount: C.int; );

<* EXTERNAL QPaintEngine_drawPoints1 *>
PROCEDURE QPaintEngine_drawPoints1
  (self: QPaintEngine; points: ADDRESS; pointCount: C.int; );

<* EXTERNAL QPaintEngine_drawPolygon *>
PROCEDURE QPaintEngine_drawPolygon
  (self: QPaintEngine; points: ADDRESS; pointCount, mode: C.int; );

<* EXTERNAL QPaintEngine_drawPolygon1 *>
PROCEDURE QPaintEngine_drawPolygon1
  (self: QPaintEngine; points: ADDRESS; pointCount, mode: C.int; );

<* EXTERNAL QPaintEngine_drawTiledPixmap *>
PROCEDURE QPaintEngine_drawTiledPixmap
  (self: QPaintEngine; r, pixmap, s: ADDRESS; );

<* EXTERNAL QPaintEngine_drawImage *>
PROCEDURE QPaintEngine_drawImage
  (self: QPaintEngine; r, pm, sr: ADDRESS; flags: C.int; );

<* EXTERNAL QPaintEngine_drawImage1 *>
PROCEDURE QPaintEngine_drawImage1
  (self: QPaintEngine; r, pm, sr: ADDRESS; );

<* EXTERNAL QPaintEngine_setPaintDevice *>
PROCEDURE QPaintEngine_setPaintDevice
  (self: QPaintEngine; device: ADDRESS; );

<* EXTERNAL QPaintEngine_paintDevice *>
PROCEDURE QPaintEngine_paintDevice (self: QPaintEngine; ): ADDRESS;

<* EXTERNAL QPaintEngine_setSystemClip *>
PROCEDURE QPaintEngine_setSystemClip
  (self: QPaintEngine; baseClip: ADDRESS; );

<* EXTERNAL QPaintEngine_systemClip *>
PROCEDURE QPaintEngine_systemClip (self: QPaintEngine; ): ADDRESS;

<* EXTERNAL QPaintEngine_setSystemRect *>
PROCEDURE QPaintEngine_setSystemRect (self: QPaintEngine; rect: ADDRESS; );

<* EXTERNAL QPaintEngine_systemRect *>
PROCEDURE QPaintEngine_systemRect (self: QPaintEngine; ): ADDRESS;

<* EXTERNAL QPaintEngine_coordinateOffset *>
PROCEDURE QPaintEngine_coordinateOffset (self: QPaintEngine; ): ADDRESS;

<* EXTERNAL QPaintEngine_fix_neg_rect *>
PROCEDURE QPaintEngine_fix_neg_rect
  (self: QPaintEngine; x, y, w, h: C.int; );

<* EXTERNAL QPaintEngine_testDirty *>
PROCEDURE QPaintEngine_testDirty (self: QPaintEngine; df: C.int; ):
  BOOLEAN;

<* EXTERNAL QPaintEngine_setDirty *>
PROCEDURE QPaintEngine_setDirty (self: QPaintEngine; df: C.int; );

<* EXTERNAL QPaintEngine_clearDirty *>
PROCEDURE QPaintEngine_clearDirty (self: QPaintEngine; df: C.int; );

<* EXTERNAL QPaintEngine_hasFeature *>
PROCEDURE QPaintEngine_hasFeature (self: QPaintEngine; feature: C.int; ):
  BOOLEAN;

<* EXTERNAL QPaintEngine_syncState *>
PROCEDURE QPaintEngine_syncState (self: QPaintEngine; );

<* EXTERNAL QPaintEngine_isExtended *>
PROCEDURE QPaintEngine_isExtended (self: QPaintEngine; ): BOOLEAN;

TYPE QPaintEngine <: ADDRESS;

<* EXTERNAL QPaintEngineState_state *>
PROCEDURE QPaintEngineState_state (self: QPaintEngineState; ): C.int;

<* EXTERNAL QPaintEngineState_pen *>
PROCEDURE QPaintEngineState_pen (self: QPaintEngineState; ): ADDRESS;

<* EXTERNAL QPaintEngineState_brush *>
PROCEDURE QPaintEngineState_brush (self: QPaintEngineState; ): ADDRESS;

<* EXTERNAL QPaintEngineState_brushOrigin *>
PROCEDURE QPaintEngineState_brushOrigin (self: QPaintEngineState; ):
  ADDRESS;

<* EXTERNAL QPaintEngineState_backgroundBrush *>
PROCEDURE QPaintEngineState_backgroundBrush (self: QPaintEngineState; ):
  ADDRESS;

<* EXTERNAL QPaintEngineState_backgroundMode *>
PROCEDURE QPaintEngineState_backgroundMode (self: QPaintEngineState; ):
  C.int;

<* EXTERNAL QPaintEngineState_font *>
PROCEDURE QPaintEngineState_font (self: QPaintEngineState; ): ADDRESS;

<* EXTERNAL QPaintEngineState_matrix *>
PROCEDURE QPaintEngineState_matrix (self: QPaintEngineState; ): ADDRESS;

<* EXTERNAL QPaintEngineState_transform *>
PROCEDURE QPaintEngineState_transform (self: QPaintEngineState; ): ADDRESS;

<* EXTERNAL QPaintEngineState_clipOperation *>
PROCEDURE QPaintEngineState_clipOperation (self: QPaintEngineState; ):
  C.int;

<* EXTERNAL QPaintEngineState_clipRegion *>
PROCEDURE QPaintEngineState_clipRegion (self: QPaintEngineState; ):
  ADDRESS;

<* EXTERNAL QPaintEngineState_isClipEnabled *>
PROCEDURE QPaintEngineState_isClipEnabled (self: QPaintEngineState; ):
  BOOLEAN;

<* EXTERNAL QPaintEngineState_opacity *>
PROCEDURE QPaintEngineState_opacity (self: QPaintEngineState; ): C.double;

<* EXTERNAL QPaintEngineState_brushNeedsResolving *>
PROCEDURE QPaintEngineState_brushNeedsResolving
  (self: QPaintEngineState; ): BOOLEAN;

<* EXTERNAL QPaintEngineState_penNeedsResolving *>
PROCEDURE QPaintEngineState_penNeedsResolving (self: QPaintEngineState; ):
  BOOLEAN;

<* EXTERNAL Delete_QPaintEngineState *>
PROCEDURE Delete_QPaintEngineState (self: QPaintEngineState; );

TYPE QPaintEngineState <: ADDRESS;

END QtPaintEngineRaw.
