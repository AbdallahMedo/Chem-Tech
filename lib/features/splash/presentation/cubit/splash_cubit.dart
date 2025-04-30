

import 'package:chem_tech_gravity_app/features/splash/presentation/cubit/splash_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashInitial());

  void navigate() async {
    await Future.delayed(const Duration(seconds: 3));
    emit(SplashFinished());
  }
}
