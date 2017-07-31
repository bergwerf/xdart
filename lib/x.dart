// Copyright (c) 2017, Herman Bergwerf. All rights reserved.
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file.

import 'dart:io';
import 'dart:async';
import 'dart:typed_data';

import 'package:x/utils.dart';
import 'package:x/structs.dart';

class X11Info {
  final Socket socket;
  final ChunkedStreamReader<int> reader;
  X11ConnectionReply header;

  X11Info(this.socket, this.reader);
}

Future<X11ConnectionReply> x11Handshake(X11Info info) async {
  // Read .Xauthority file.
  final xauthPath = Platform.environment['XAUTHORITY'];
  final xauthData = new File(xauthPath).readAsBytesSync();
  const protocol = 'MIT-MAGIC-COOKIE-1';
  final authdata = xauthData.sublist(xauthData.length - 16);

  final req = new X11ConnectionRequest();
  req.byteOrder = 'l'.codeUnitAt(0); // Dart uses Big endian by default.
  req.protocolMajorVersion = 11;
  req.protocolMinorVersion = 0;
  req.authorizationProtocolNameLength = protocol.length;
  req.authorizationProtocolDataLength = authdata.length;
  req.authorizationProtocolName = new Uint8List.fromList(protocol.codeUnits);
  req.authorizationProtocolData = new Uint8List.fromList(authdata);
  write(info.socket, req);

  // TODO: should be able to handle success = 0 replies (and read reason).
  final reply = new X11ConnectionReply();
  await read(info.reader, reply);
  return reply;
}

var _x11id = 0;
int x11GenerateId(X11ConnectionReply info) {
  return (_x11id++ | info.resourceIdBase);
}

void x11CreateGC(X11Info info, int ctxId, int rootId) {
  final req = new X11CreateGC();
  req.requestLength = 4;
  req.cid = ctxId;
  req.drawable = rootId;

  write(info.socket, req);
}

void x11CreateWindow(X11Info info, int winId, int parent, int x, int y, int w,
    int h, int borderWidth, int windowClass, int visualId) {
  final req = new X11CreateWindow();
  req.requestLength = 8;
  req.wid = winId;
  req.parent = parent;
  req.x = x;
  req.y = y;
  req.w = w;
  req.h = h;
  req.borderWidth = borderWidth;
  req.windowClass = windowClass;
  req.visualId = visualId;

  write(info.socket, req);
}

void x11MapWindow(X11Info info, int winId) {
  final req = new X11MapWindow();
  req.requestLength = 2;
  req.window = winId;

  write(info.socket, req);
}
