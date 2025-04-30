import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../home/data/presentation/cubit/scan_cubit.dart';
import '../../../home/data/presentation/cubit/scan_state.dart';

AppBar buildDeviceAppBar(BuildContext context, String nameOrId) {
  return AppBar(
    title: Text(nameOrId),
    automaticallyImplyLeading: false,
    backgroundColor: Colors.transparent,
    actions: [
      BlocBuilder<ScanCubit, ScanState>(builder: (context, state) {
        if (state is ScanSuccess && state.devices.isEmpty) {
          return IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ScanCubit>().startScan();
            },
          );
        }
        return const SizedBox.shrink();
      }),
    ],
  );
}
