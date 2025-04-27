import 'package:chem_tech_gravity_app/features/home/data/presentation/cubit/scan_state.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScanCubit extends Cubit<ScanState> {
  ScanCubit() : super(ScanInitial());

  Future<void> startScan() async {
    emit(ScanLoading());
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
      FlutterBluePlus.scanResults.listen((devices) {
        emit(ScanSuccess(devices));
      });
    } catch (e) {
      emit(ScanFailure(e.toString()));
    }

  }



}
