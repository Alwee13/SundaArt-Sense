import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sundaart_sense/features/core/onboarding_screen.dart';
import 'package:sundaart_sense/main.dart'; // AuthGate

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final bool onboardingComplete = prefs.getBool('onboardingComplete') ?? false;

    Timer(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => onboardingComplete ? const AuthGate() : const OnboardingScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const _GlassSplashNoBox();
  }
}

class _GlassSplashNoBox extends StatelessWidget {
  const _GlassSplashNoBox();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // BACKGROUND: gradasi ungu (bahan “glass”)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF9B5BFF), Color(0xFF7C3AED)],
                ),
              ),
            ),
          ),
          // Overlay putih tipis agar konten nyaman dibaca
          Positioned.fill(
            child: Container(color: Colors.white.withOpacity(0.85)),
          ),

          // Konten tengah: TANPA BOX/PANEL
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // LOGO — pastikan ada di assets/branding/sundaart_logo.png
                  Image.asset(
                    'assets/branding/sundaart_logo.png',
                    width: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.image, size: 96, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'SundaArt Sense',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color.fromARGB(255, 23, 52, 105),
                      letterSpacing: .2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Loader simple (tanpa capsule box)
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      backgroundColor: Colors.white.withOpacity(0.25),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
