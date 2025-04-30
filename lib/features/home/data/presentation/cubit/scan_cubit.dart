import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'scan_state.dart';

class ScanCubit extends Cubit<ScanState> {
  StreamSubscription<List<ScanResult>>? _scanSubscription;

  ScanCubit() : super(ScanInitial());

  Future<void> startScan() async {
    try {
      emit(ScanLoading());

      // Cancel any previous scan listener if it exists
      await _scanSubscription?.cancel();

      // Start scanning with timeout
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));

      // Listen once and emit results, then cancel
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        emit(ScanSuccess(results));
      });
    } catch (e) {
      emit(ScanFailure(e.toString()));
    }
  }

  Future<bool> isBluetoothOn() async {
    return await FlutterBluePlus.isOn;
  }

  @override
  Future<void> close() {
    _scanSubscription?.cancel();
    return super.close();
  }
}
