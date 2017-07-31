// Copyright (c) 2017, Herman Bergwerf. All rights reserved.
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file.

library x.structs;

import 'dart:typed_data';

import 'package:x/utils.dart';

class X11ConnectionRequest {
  @uint8
  int byteOrder;
  @uint8
  int unused1 = 0;
  @uint16
  int protocolMajorVersion = 11;
  @uint16
  int protocolMinorVersion = 0;
  @uint16
  int authorizationProtocolNameLength = 0;
  @uint16
  int authorizationProtocolDataLength = 0;
  @uint16
  int unused2 = 0;
  @bytes
  Uint8List authorizationProtocolName;
  @uint16
  int unused3 = 0;
  @bytes
  Uint8List authorizationProtocolData;
}

class X11ConnectionReply {
  @uint8
  int success;
  @uint8
  int pad1;
  @uint16
  int protocolMajorVersion = 11;
  @uint16
  int protocolMinorVersion = 0;
  @uint16
  int replyLength;
  @uint32
  int releaseNumber;
  @uint32
  int resourceIdBase;
  @uint32
  int resourceIdMask;
  @uint32
  int motionBufferSize;
  @uint16
  int lengthOfVendor;
  @uint16
  int maximumRequestLength;
  @uint8
  int screenCount;
  @uint8
  int pixmapFormatsCount;
  @uint8
  int imageByteOrder;
  @uint8
  int bitmapFormatBitOrder;
  @uint8
  int bitmapFormatScanlineUnit;
  @uint8
  int bitmapFormatScanlinePad;
  @uint8
  int minKeycode;
  @uint8
  int maxKeycode;
  @uint32
  int unused1;

  @MessageList('lengthOfVendor')
  List<Uint8> vendor;

  @MessageList('pixmapFormatsCount')
  List<X11PixmapFormat> pixmapFormats;

  @MessageList('screenCount')
  List<X11Screen> screens;
}

class Uint8 {
  @uint8
  int value;
}

class X11PixmapFormat {
  @uint8
  int depth;
  @uint8
  int bitsPerPixel;
  @uint8
  int scanlinePad;
  @uint8
  int unused1;
  @uint32
  int unused2;
}

class X11Screen {
  @uint32
  int root;
  @uint32
  int defaultColormap;
  @uint32
  int whitePixel;
  @uint32
  int blackPixel;
  @uint32
  int currentInputMasks;
  @uint16
  int widthInPixels;
  @uint16
  int heightInPixels;
  @uint16
  int widthInMillimeters;
  @uint16
  int heightInMillimeters;
  @uint16
  int minInstalledMaps;
  @uint16
  int maxInstalledMaps;
  @uint32
  int rootVisual;
  @uint8
  int backingStores;
  @uint8
  int saveUnders;
  @uint8
  int rootDepth;
  @uint8
  int depthDetailCount;

  @MessageList('depthDetailCount')
  List<X11DepthDetail> depthDetails;
}

class X11DepthDetail {
  @uint8
  int depth;
  @uint8
  int unused1;
  @uint16
  int visualtypeCount;
  @uint32
  int unused2;

  @MessageList('visualtypeCount')
  List<X11VisualType> visualtypes;
}

class X11VisualType {
  @uint32
  int visualId;
  @uint8
  int visualTypeClass;
  @uint8
  int bitsPerRgbValue;
  @uint16
  int colormapEntries;
  @uint32
  int redMask;
  @uint32
  int greenMask;
  @uint32
  int blueMask;
  @uint32
  int unused1;
}

final x11GCFunction = 1 << 0;
final x11GCPlaneMask = 1 << 1;
final x11GCForeground = 1 << 2;
final x11GCBackground = 1 << 3;
final x11GCLineWidth = 1 << 4;
final x11GCLineStyle = 1 << 5;
final x11GCCapStyle = 1 << 6;
final x11GCJoinStyle = 1 << 7;
final x11GCFillStyle = 1 << 8;
final x11GCFillRule = 1 << 9;
final x11GCTile = 1 << 10;
final x11GCStipple = 1 << 11;
final x11GCTileStipXOrigin = 1 << 12;
final x11GCTileStipYOrigin = 1 << 13;
final x11GCFont = 1 << 14;
final x11GCSubwindowMode = 1 << 15;
final x11GCGraphicsExposures = 1 << 16;
final x11GCClipXOrigin = 1 << 17;
final x11GCClipYOrigin = 1 << 18;
final x11GCClipMask = 1 << 19;
final x11GCDashOffset = 1 << 20;
final x11GCDashList = 1 << 21;
final x11GCArcMode = 1 << 22;

class X11CreateGC {
  @uint8
  int opcode = 0x37;
  @uint8
  int unused1 = 0;
  @uint16
  int requestLength;
  @uint32
  int cid;
  @uint32
  int drawable;
  @uint32
  int valueMask = 0;
}

class X11CreateWindow {
  @uint8
  int opcode = 0x01;
  @uint8
  int depth = 0;
  @uint16
  int requestLength;
  @uint32
  int wid;
  @uint32
  int parent;
  @uint16
  int x;
  @uint16
  int y;
  @uint16
  int w;
  @uint16
  int h;
  @uint16
  int borderWidth;
  @uint16
  int windowClass;
  @uint32
  int visualId;
  @uint32
  int valueMask = 0;
}

class X11MapWindow {
  @uint8
  int opcode = 0x08;
  @uint8
  int unused1 = 0;
  @uint16
  int requestLength;
  @uint32
  int window;
}
