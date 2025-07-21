import 'package:equatable/equatable.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

abstract class ScanState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ScanInitial extends ScanState {}

class ScanLoading extends ScanState {}

class ScanSuccess extends ScanState {
  final List<ScanResult> devices;

  ScanSuccess(this.devices);

  @override
  List<Object?> get props => [devices];
}

class ScanFailure extends ScanState {
  final String error;

  ScanFailure(this.error);

  @override
  List<Object?> get props => [error];
}
