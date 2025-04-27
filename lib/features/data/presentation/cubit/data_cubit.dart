import 'package:bloc/bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../models/data_struct.dart';

class DataCubit extends Cubit<DataState> {
  final BluetoothDevice? device;
  BluetoothCharacteristic? rxChar;
  BluetoothCharacteristic? txChar;

  // Initialize the cubit with the device
  DataCubit({this.device}) : super(DataInitial());

  // Connect to the Bluetooth device and discover its services
  Future<void> connectToDevice(device) async {
    try {
      emit(DataLoading());  // Show loading state when connecting

      await device.connect(autoConnect: false);
      List<BluetoothService> services = await device.discoverServices();

      // Loop through services and find characteristics
      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.write) {
            rxChar = characteristic;  // For sending data
          }
          if (characteristic.properties.notify) {
            txChar = characteristic;  // For receiving data
            await txChar!.setNotifyValue(true);

            // Listen for data from the device
            txChar!.lastValueStream.listen((value) {
              if (value.length == 16) {
                final receivedData = DataStruct.fromBytes(value);
                emit(DataReceived(receivedData));  // Emit the received data
              }
            });
          }
        }
      }
    } catch (e) {
      emit(DataError("Failed to connect or retrieve services: $e"));
    }
  }

  // Send data to the Bluetooth device
  Future<void> sendData(DataStruct dataStruct) async {
    if (rxChar == null) {
      emit(DataError("No writable characteristic found"));
      return;
    }

    try {
      final bytes = dataStruct.toBytes();  // Convert DataStruct to bytes
      await rxChar!.write(bytes, withoutResponse: false);
      emit(DataSent("Data sent successfully"));  // Data was successfully sent
    } catch (e) {
      emit(DataError("Failed to send data: $e"));
    }
  }

  // Disconnect from the device
  Future<void> disconnectFromDevice() async {
    await device!.disconnect();
  }
}

abstract class DataState {
  const DataState();

  @override
  List<Object> get props => [];
}

// Initial state
class DataInitial extends DataState {}

// Loading state while connecting or sending data
class DataLoading extends DataState {}

// State when data has been sent successfully
class DataSent extends DataState {
  final String message;

  const DataSent(this.message);

  @override
  List<Object> get props => [message];
}

// State when data is received from the device
class DataReceived extends DataState {
  final DataStruct dataStruct;

  const DataReceived(this.dataStruct);

  @override
  List<Object> get props => [dataStruct];
}

// State when an error occurs
class DataError extends DataState {
  final String errorMessage;

  const DataError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
