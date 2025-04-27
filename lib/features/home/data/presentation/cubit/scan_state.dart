import 'package:flutter_blue_plus/flutter_blue_plus.dart';

abstract class ScanState {}

class ScanInitial extends ScanState {}

class ScanLoading extends ScanState {}

class ScanSuccess extends ScanState {
  final List<ScanResult> devices;
  ScanSuccess(this.devices);
}

class ScanFailure extends ScanState {
  final String errorMessage;
  ScanFailure(this.errorMessage);
}
