

// Abstract class representing the various states for data-related operations.
import '../../models/data_struct.dart';

abstract class DataState {
  const DataState();

  @override
  List<Object> get props => [];
}

// Initial state when the cubit is not yet initialized or waiting for an action.
class DataInitial extends DataState {}

// Loading state when data is being sent or received.
class DataLoading extends DataState {}

// State representing the successful sending of data.
class DataSent extends DataState {
  final String message; // A message to display when data is sent successfully.

  const DataSent(this.message);

  @override
  List<Object> get props => [message]; // Equatable props for comparison.
}

// State when data is successfully received from the Bluetooth device.
class DataReceived extends DataState {
  final DataStruct dataStruct; // The data received from the device.

  const DataReceived(this.dataStruct);

  @override
  List<Object> get props => [dataStruct]; // Equatable props for comparison.
}

// State when there is an error during any data operation.
class DataError extends DataState {
  final String errorMessage; // The error message to display when an error occurs.

  const DataError(this.errorMessage);

  @override
  List<Object> get props => [errorMessage]; // Equatable props for comparison.
}
