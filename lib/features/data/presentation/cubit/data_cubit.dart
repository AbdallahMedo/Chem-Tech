import 'package:bloc/bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../models/data_struct.dart';

class DataCubit extends Cubit<DataState> {
  final BluetoothDevice? device;
  BluetoothCharacteristic? rxChar;
  BluetoothCharacteristic? txChar;

  DataCubit({this.device}) : super(DataInitial());

  Future<void> connectToDevice(device) async {
    try {
      emit(DataLoading());
      await device.connect(autoConnect: false);
      List<BluetoothService> services = await device.discoverServices();

      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.write) {
            rxChar = characteristic;
          }
          if (characteristic.properties.notify) {
            txChar = characteristic;
            await txChar!.setNotifyValue(true);

            txChar!.lastValueStream.listen((value) {
              if (value.length == 16) {
                final receivedData = DataStruct.fromBytes(value);
                emit(DataReceived(receivedData));
              }
            });
          }
        }
      }
    } catch (e) {
      emit(DataError("Failed to connect or retrieve services: $e"));
    }
  }

  Future<void> sendData(DataStruct dataStruct) async {
    if (rxChar == null) {
      emit(DataError("No writable characteristic found"));
      return;
    }

    try {
      final bytes = dataStruct.toBytes();
      await rxChar!.write(bytes, withoutResponse: false);
      emit(DataSent("Data sent successfully"));
    } catch (e) {
      emit(DataError("Failed to send data: $e"));
    }
  }

  Future<void> disconnectFromDevice() async {
    await device!.disconnect();
  }
}

abstract class DataState {
  const DataState();

  List<Object> get props => [];
}

class DataInitial extends DataState {}

class DataLoading extends DataState {}

class DataSent extends DataState {
  final String message;

  const DataSent(this.message);

  @override
  List<Object> get props => [message];
}

class DataReceived extends DataState {
  final DataStruct dataStruct;

  const DataReceived(this.dataStruct);

  @override
  List<Object> get props => [dataStruct];
}

class DataError extends DataState {
  final String errorMessage;

  const DataError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
