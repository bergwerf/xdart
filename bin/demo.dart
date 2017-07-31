// Copyright (c) 2017, Herman Bergwerf. All rights reserved.
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file.

import 'dart:io';
import 'dart:async';

import 'package:x/x.dart';
import 'package:x/utils.dart';

Future main() async {
  final socket = await Socket.connect('localhost', 6000);
  final reader = new ChunkedStreamReader<int>(socket, socket.close);

  // If we want to receive window close events without closing the connection,
  // it is neccessary to integrate with the WM. This can be achieved through
  // WM_DESTROY_WINDOW, see: https://stackoverflow.com/questions/10792361.

  final info = new X11Info(socket, reader);
  info.header = await x11Handshake(info);

  // Create graphics context.
  final rootId = info.header.screens[0].root;
  final ctxId = x11GenerateId(info.header);
  x11CreateGC(info, ctxId, rootId);

  // Create window.
  final rootVisualId = info.header.screens[0].rootVisual;
  final winId = x11GenerateId(info.header);
  x11CreateWindow(info, winId, rootId, 200, 200, 400, 400, 1, 1, rootVisualId);
  x11MapWindow(info, winId);
}
