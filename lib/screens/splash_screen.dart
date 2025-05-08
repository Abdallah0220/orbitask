import 'dart:math';
import 'package:flutter/material.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();

    // إنشاء أكثر من controller للكواكب بسرعات مختلفة
    _controllers = List.generate(4, (index) {
      return AnimationController(
        vsync: this,
        duration: Duration(seconds: 2 + index * 2),
      )..repeat();
    });

    // الانتقال بعد 3 ثوانٍ
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget buildPlanetOrbit({
    required double radius,
    required Color color,
    required AnimationController controller,
    double planetSize = 8,
  }) {
    return SizedBox(
      width: 2 * radius + 20,
      height: 2 * radius + 20,
      child: AnimatedBuilder(
        animation: controller,
        builder: (_, __) {
          final angle = controller.value * 2 * pi;
          final x = radius * cos(angle);
          final y = radius * sin(angle);

          return Stack(
            alignment: Alignment.center,
            children: [
              // المدار نفسه (اختياري)
              Container(
                width: 2 * radius,
                height: 2 * radius,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
              ),
              Positioned(
                left: radius + x,
                top: radius + y,
                child: Container(
                  width: planetSize,
                  height: planetSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // مركز الشمس + الكواكب
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // اللوجو
            Image.asset(
              'assets/images/logo1.png',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 30),

            // النظام الشمسي
            Stack(
              alignment: Alignment.center,
              children: [
                // الشمس
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF5F33E1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple,
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                // كواكب بمدارات مختلفة
                buildPlanetOrbit(
                  radius: 25,
                  color: Colors.orange,
                  controller: _controllers[0],
                ),
                buildPlanetOrbit(
                  radius: 40,
                  color: Colors.blue,
                  controller: _controllers[1],
                  planetSize: 10,
                ),
                buildPlanetOrbit(
                  radius: 60,
                  color: Colors.green,
                  controller: _controllers[2],
                  planetSize: 12,
                ),
                buildPlanetOrbit(
                  radius: 80,
                  color: Colors.redAccent,
                  controller: _controllers[3],
                  planetSize: 14,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
