// Copyright (c) 2017, Herman Bergwerf. All rights reserved.
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file.

part of x.utils;

class MessageInteger {
  final int size;
  final bool signed;
  const MessageInteger(this.size, this.signed);
}

class MessageList {
  final String lengthSymbolName;
  const MessageList(this.lengthSymbolName);
}

class BinaryData {
  const BinaryData();
}

const uint8 = const MessageInteger(1, false);
const uint16 = const MessageInteger(2, false);
const uint32 = const MessageInteger(4, false);
const bytes = const BinaryData();

class _Integer {
  final int size, value;
  _Integer(this.size, this.value);
}

/// Write annotated class to socket.
void write(Socket sock, data) {
  final integers = _pack(data);
  final bytes = _write(integers);
  sock.add(new Uint8List.view(bytes.buffer));
}

/// Read annotated class from socket.
Future<Null> read(ChunkedStreamReader<int> reader, object) async {
  await _unpack(reader, object);
}

/// Pack class into integer list based on annotations.
List<_Integer> _pack(object) {
  final im = reflect(object);
  final cm = im.type;
  final output = new List<_Integer>();

  for (final symbol in cm.declarations.keys) {
    final d = cm.declarations[symbol];
    if (d is VariableMirror) {
      for (final meta in d.metadata) {
        final annotation = meta.reflectee;
        if (annotation is MessageInteger) {
          final value = im.getField(symbol).reflectee;
          output.add(new _Integer(annotation.size, value));
          break;
        } else if (annotation is BinaryData) {
          var elmSize = 0;
          final data = im.getField(symbol).reflectee;
          if (data is TypedData) {
            elmSize = data.elementSizeInBytes;
          }
          if (data is List) {
            // This not not so great.
            for (final i in data) {
              output.add(new _Integer(elmSize, i));
            }
          }
          break;
        }
      }
    }
  }

  return output;
}

/// Unpack data into annotated object.
Future<Null> _unpack(ChunkedStreamReader<int> reader, object) async {
  final im = reflect(object);
  final cm = im.type;
  for (final symbol in cm.declarations.keys) {
    final d = cm.declarations[symbol];
    if (d is VariableMirror) {
      for (final meta in d.metadata) {
        final annotation = meta.reflectee;
        if (annotation is MessageInteger) {
          // Be careful with endianness.
          im.setField(symbol, uintB(await reader.take(annotation.size)));
          break;
        } else if (annotation is MessageList) {
          // Find list length.
          final lengthSymbol = new Symbol(annotation.lengthSymbolName);
          final int length = im.getField(lengthSymbol).reflectee;

          // Find list template class.
          final ClassMirror elmCm = d.type.typeArguments.first;

          // Read all elements one by one.
          final list = new List(length);
          for (var i = 0; i < length; i++) {
            final instance = elmCm.newInstance(const Symbol(''), []).reflectee;
            await _unpack(reader, instance);
            list[i] = instance;
          }

          im.setField(symbol, list);
          break;
        }
      }
    }
  }
}

/// Write integers to byte data.
ByteData _write(List<_Integer> ints) {
  final size = ints.fold(0, (v, i) => v + i.size);
  final data = new ByteData(size);
  var offset = 0;
  for (final integer in ints) {
    switch (integer.size) {
      case 1:
        data.setUint8(offset, integer.value);
        break;
      case 2:
        data.setUint16(offset, integer.value, Endianness.LITTLE_ENDIAN);
        break;
      case 4:
        data.setUint32(offset, integer.value, Endianness.LITTLE_ENDIAN);
        break;
    }
    offset += integer.size;
  }
  return data;
}
