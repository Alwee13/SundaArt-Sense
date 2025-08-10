import 'dart:ui'; // untuk BackdropFilter (blur di tombol bulat)
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:sundaart_sense/main.dart'; // AuthGate

// Model data onboarding
class OnboardingPageData {
  final String imageUrl; // bisa URL (http...) atau path asset (assets/...)
  final String title;
  final String description;

  OnboardingPageData({
    required this.imageUrl,
    required this.title,
    required this.description,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  bool _isLastPage = false;

  // Campur: sebagian asset, sebagian URL
  final List<OnboardingPageData> _pages = [
    OnboardingPageData(
      imageUrl: 'assets/onboarding/1.png', // ASSET
      title: 'Jelajahi Ragam Event',
      description:
          'Temukan jadwal pameran, pagelaran, dan lokakarya seni budaya Sunda terkini.',
    ),
    OnboardingPageData(
      imageUrl: 'assets/onboarding/2.png', // ASSET
      title: 'Asah Wawasan Anda',
      description:
          'Uji pengetahuan tentang sejarah, tradisi, dan kesenian Sunda melalui kuis interaktif.',
    ),
    OnboardingPageData(
      imageUrl: 'https://cdn-icons-png.freepik.com/512/9662/9662212.png', // URL
      title: 'Raih Peringkat Tertinggi',
      description:
          'Bersaing dengan pengguna lain di papan peringkat untuk jadi jawara budaya Sunda!',
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache asset supaya mulus
    for (final p in _pages) {
      if (!_isNetworkSrc(p.imageUrl)) {
        precacheImage(AssetImage(p.imageUrl), context);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingComplete', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AuthGate()),
    );
  }

  bool _isNetworkSrc(String src) => src.startsWith('http');

  Widget _buildOnboardingImage(String src) {
  // Tinggi konsisten untuk semua halaman (boleh kamu ubah 0.36 → 0.32–0.42)
  final double h = MediaQuery.of(context).size.height * 0.36;

  Widget img;
  if (_isNetworkSrc(src)) {
    img = Image.network(
      src,
      fit: BoxFit.contain,      // ⬅️ supaya “fit” tanpa crop
      alignment: Alignment.center,
      filterQuality: FilterQuality.high,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (_, __, ___) =>
          Icon(Icons.image_not_supported, size: h * 0.5, color: Colors.grey[300]),
    );
  } else {
    img = Image.asset(
      src,
      fit: BoxFit.contain,      // ⬅️ supaya “fit” tanpa crop
      alignment: Alignment.center,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, __, ___) =>
          Icon(Icons.image_not_supported, size: h * 0.5, color: Colors.grey[300]),
    );
  }

  // Bungkus dengan SizedBox agar tinggi tetap & swipe nggak “meloncat”
  return SizedBox(
    height: h,
    width: double.infinity,
    child: Center(child: img),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // BACKGROUND: gradient ungu + overlay putih tipis
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
          Positioned.fill(
            child: Container(color: Colors.white.withOpacity(0.85)),
          ),

          SafeArea(
            child: Column(
              children: [
                // Halaman yang bisa di-swipe
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _pages.length,
                      onPageChanged: (index) {
                        setState(() => _isLastPage = (index == _pages.length - 1));
                      },
                      itemBuilder: (context, index) {
                        return _buildPage(_pages[index]);
                      },
                    ),
                  ),
                ),

                // Kontrol bawah — TANPA BOX (hanya indikator + tombol bulat kaca)
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SmoothPageIndicator(
                          controller: _pageController,
                          count: _pages.length,
                          effect: ExpandingDotsEffect(
                            dotHeight: 10,
                            dotWidth: 10,
                            activeDotColor: const Color(0xFF8A4DFF),
                            dotColor: Colors.black.withOpacity(0.2),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: _completeOnboarding,
                              child: Text(
                                'LEWATI',
                                style: TextStyle(
                                  color: Colors.black.withOpacity(0.65),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            _GlassCircleButton(
                              onTap: _isLastPage
                                  ? _completeOnboarding
                                  : () {
                                      _pageController.nextPage(
                                        duration: const Duration(milliseconds: 400),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                              icon: Icons.arrow_forward_ios_rounded,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Satu halaman — TANPA BOX (gambar + teks polos)
  Widget _buildPage(OnboardingPageData pageData) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildOnboardingImage(pageData.imageUrl),
          const SizedBox(height: 24),
          Text(
            pageData.title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            pageData.description,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              height: 1.5,
              color: Colors.black.withOpacity(0.65),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Tombol bulat kaca (Next) — satu-satunya elemen glass di area kontrol
class _GlassCircleButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;

  const _GlassCircleButton({
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: const Color(0xFF8A4DFF).withOpacity(0.25),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF9B5BFF).withOpacity(0.26),
                    Colors.white.withOpacity(0.10),
                    const Color(0xFF7C3AED).withOpacity(0.22),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.30)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withOpacity(0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
