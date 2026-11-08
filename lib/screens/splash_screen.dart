import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/theme_controller.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const SplashScreen({Key? key, required this.onFinish}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1400))
    ..repeat();
  Timer? _timer;
  static const _word = 'Quizly';

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 3200), () {
      if (mounted) widget.onFinish();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final g = ThemeController.instance.palette.gradient;
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight, colors: g),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _c,
              builder: (_, __) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_word.length, (i) {
                  // gelombang naik-turun, tiap huruf punya jeda fase
                  final dy = math.sin(_c.value * 2 * math.pi - i * 0.7) * 16;
                  return Transform.translate(
                    offset: Offset(0, dy),
                    child: Text(_word[i],
                        style: const TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 2)),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            Text('Learn. Compete. Level up.',
                style: TextStyle(
                    color: Colors.white.withOpacity(.85), fontSize: 15)),
          ],
        ),
      ),
    );
  }
}