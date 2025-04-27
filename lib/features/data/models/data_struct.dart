import 'dart:typed_data';

class DataStruct {
  int flag1;
  int flag2;
  int value1;
  int value2;
  int value3;

  DataStruct({
    required this.flag1,
    required this.flag2,
    required this.value1,
    required this.value2,
    required this.value3,
  });

  List<int> toBytes() {
    final data = ByteData(16);
    data.setUint8(0, '<'.codeUnitAt(0));
    data.setUint8(1, flag1);
    data.setUint8(2, flag2);
    data.setUint32(3, value1, Endian.little);
    data.setUint32(7, value2, Endian.little);
    data.setUint32(11, value3, Endian.little);
    data.setUint8(15, '>'.codeUnitAt(0));
    return data.buffer.asUint8List();
  }

  static DataStruct fromBytes(List<int> bytes) {
    final byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    return DataStruct(
      flag1: byteData.getUint8(1),
      flag2: byteData.getUint8(2),
      value1: byteData.getUint32(3, Endian.little),
      value2: byteData.getUint32(7, Endian.little),
      value3: byteData.getUint32(11, Endian.little),
    );
  }
}
