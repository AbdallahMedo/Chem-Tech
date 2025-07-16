import 'package:chem_tech_gravity_app/core/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'core/id/service_locator.dart';
import 'features/data/presentation/cubit/data_cubit.dart';
import 'features/home/presentation/cubit/scan_cubit.dart';
import 'features/splash/presentation/views/splash_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupServiceLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context){
    return MultiProvider(
      providers: [
        BlocProvider(create: (_) => DataCubit()),
        BlocProvider(create: (_) => ScanCubit()),
      ],
      child: GetMaterialApp(
        theme: ThemeData.light().copyWith(scaffoldBackgroundColor: kPrimaryColor,),
        debugShowCheckedModeBanner: false,
        home: const SplashView(),
      ),
    );
  }
}
