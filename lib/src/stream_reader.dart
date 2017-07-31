// Copyright (c) 2017, Herman Bergwerf. All rights reserved.
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file.

part of x.utils;

final _log = new Logger('ccp4.gzip');

/// Not enough data available in stream.
class NotEnoughDataException implements Exception {
  NotEnoughDataException();
}

/// Async generic stream reader. Can be connected to a Stream<List<T>>.
class ChunkedStreamReader<T> {
  final Stream<List<T>> _stream;
  final _buffer = new List<T>();
  final Function _onDone;
  Completer<bool> _pending;
  var _done = false;

  ChunkedStreamReader(this._stream, this._onDone) {
    _pending = new Completer<bool>();
    _stream.listen((chunk) {
      _log.info('Received chunk of ${chunk.length} bytes');
      // Chunk is appended to buffer.
      _buffer.addAll(chunk);
      _pending.complete(true);
      _pending = new Completer<bool>();
    }, onDone: () {
      _done = true;
      _pending.complete(false);
      _onDone();
    });
  }

  bool get done => _done;

  /// Take next [n] elements in the buffer.
  Future<List<T>> take(int n) async {
    // Wait for enough data.
    while (_buffer.length < n) {
      if (_done) {
        throw new NotEnoughDataException();
      } else {
        await _pending.future;
      }
    }

    final result = _buffer.sublist(0, n);
    _buffer.removeRange(0, n);
    return result;
  }
}

/// Merge List<int> into single unsigned integer. Not the most efficent, but I
/// don't like redundancy. Uses little endian.
int uintB(List<int> bytes) {
  var value = 0;
  for (var i = 0; i < bytes.length; i++) {
    value |= bytes[i] << (i * 8);
  }
  return value;
}
