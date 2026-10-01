import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

/// Displays the app's launch animation before revealing [child].
class SplashScreen extends StatefulWidget {
  const SplashScreen({required this.child, super.key});

  final Widget child;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _finished = false;
  bool _animationStarted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
          setState(() => _finished = true);
        }
      });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _playAnimation(LottieComposition composition) {
    if (_animationStarted) return;
    _animationStarted = true;
    _controller
      ..duration = composition.duration
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) return widget.child;

    return Scaffold(
      body: SizedBox.expand(
        child: Lottie.asset(
          'assets/animations/rupee_animation.json',
          controller: _controller,
          fit: BoxFit.cover,
          onLoaded: _playAnimation,
          errorBuilder: (context, error, stackTrace) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && !_finished) {
                SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
                setState(() => _finished = true);
              }
            });
            return const ColoredBox(color: Colors.white);
          },
        ),
      ),
    );
  }
}
