import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:artverse/app/routes/app_pages.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    
    Future.delayed(const Duration(milliseconds: 3200), () {
      Get.offAllNamed<void>(Routes.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090F),
      body: Stack(
        fit: StackFit.expand,
        children: [
          
          Image.asset(
            'assets/images/branding/background_studio.png',
            fit: BoxFit.cover,
          ).animate().fadeIn(duration: 1200.ms),

          
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.8),
                  Colors.black.withValues(alpha: 0.2),
                  Colors.black.withValues(alpha: 0.8),
                ],
              ),
            ),
          ),

          
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.03),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00C4FF).withValues(alpha: 0.15),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/branding/app_icon.png',
                    fit: BoxFit.contain,
                  ),
                ).animate()
                 .fadeIn(duration: 800.ms)
                 .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), curve: Curves.easeOutBack)
                 .shimmer(delay: 1500.ms, duration: 1800.ms, color: Colors.white24),
                
                const SizedBox(height: 32),
                
                Text(
                  'ARTVERSE',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 12,
                  ),
                ).animate()
                 .fadeIn(delay: 400.ms, duration: 800.ms)
                 .slideY(begin: 0.2, end: 0)
                 .shimmer(delay: 2000.ms, duration: 1500.ms, color: const Color(0xFF00C4FF)),
              ],
            ),
          ),

          
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 40,
                height: 2,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF00C4FF).withValues(alpha: 0.3)),
                ),
              ),
            ).animate().fadeIn(delay: 1000.ms),
          ),
        ],
      ),
    );
  }
}
