import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/id/service_locator.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/spacing.dart';
import '../../../home/presentation/views/scan_view.dart';
import '../cubit/splash_cubit.dart';
import '../cubit/splash_state.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SplashCubit>(
      create: (_) => sl<SplashCubit>()..navigate(),
      child: const SplashViewBody(),
    );
  }
}

class SplashViewBody extends StatefulWidget {
  const SplashViewBody({super.key});

  @override
  State<SplashViewBody> createState() => _SplashViewBodyState();
}

class _SplashViewBodyState extends State<SplashViewBody>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    _initVideoPlayer();
  }

  void _initVideoPlayer() {
    _videoController = VideoPlayerController.asset('assets/images/logo.mp4')
      ..initialize().then((_) {
        setState(() {});
        _videoController.play();

        // Wait for 5 seconds, then navigate
        Future.delayed(const Duration(seconds: 5), () {
          _navigateToScanView();
        });
      });
  }



  void initScaleAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _videoController.dispose();
    super.dispose();
  }

  void _navigateToScanView() {
    Get.off(() => const ScanView());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        if (state is SplashFinished) {
          _navigateToScanView();
        }
      },
      child: Scaffold(
        backgroundColor:const Color(0xFFBBB7AE),
      // ✅ Replace with your video’s matching color
        body: Stack(
          children: [
            // Full screen background color (automatically fills screen)
            Positioned.fill(
              child: Container(color: const Color(0xFFBBB7AE)),
            ),
            // Centered video with original aspect ratio
            if (_videoController.value.isInitialized)
              Center(
                child: AspectRatio(
                  aspectRatio: _videoController.value.aspectRatio,
                  child: VideoPlayer(_videoController),
                ),
              ),
          ],
        ),
      ),
    );
  }


  Widget _buildVideo() {
    return _videoController.value.isInitialized
        ? SizedBox(
      height: 300,
      child: AspectRatio(
        aspectRatio: _videoController.value.aspectRatio,
        child: VideoPlayer(_videoController),
      ),
    )
        : const SizedBox(height: 300);
  }


  Widget _buildLoadingIndicator() {
    return const CircularProgressIndicator(
      color: kSecondaryColor,
    );
  }
}
