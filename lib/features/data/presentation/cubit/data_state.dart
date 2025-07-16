import '../../models/data_struct.dart';

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
