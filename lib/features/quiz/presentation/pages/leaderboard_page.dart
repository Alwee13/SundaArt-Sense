import 'dart:ui'; // ⬅️ wajib untuk BackdropFilter (blur)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:confetti/confetti.dart';
import 'package:sundaart_sense/features/quiz/logic/leaderboard_bloc/leaderboard_bloc.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 4));
    Future.delayed(const Duration(milliseconds: 500), () {
      _confettiController.play();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    const appBarHeight = 72.0;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: _GlassAppBar(
        title: 'Papan Peringkat',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: Stack(
        children: [
          // BACKGROUND: gradient ungu + overlay putih tipis (bahan blur)
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
          Positioned.fill(child: Container(color: Colors.white.withOpacity(0.85))),

          // KONTEN
          BlocBuilder<LeaderboardBloc, LeaderboardState>(
            builder: (context, state) {
              if (state is LeaderboardLoading || state is LeaderboardInitial) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: topPad + appBarHeight),
                    child: const CircularProgressIndicator(),
                  ),
                );
              }

              if (state is LeaderboardLoaded) {
                final topThree = state.scores.take(3).toList();

                return ListView(
                  padding: EdgeInsets.fromLTRB(16, topPad + appBarHeight + 8, 16, 16),
                  children: [
                    // PODIUM GLASS
                    AnimatedPodium(topThree: topThree),
                    const SizedBox(height: 24),

                    // DAFTAR POIN (tiap item jadi glass card)
                    ...List.generate(state.scores.length, (index) {
                      final scoreData = state.scores[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: _GlassTile(
                          child: Row(
                            children: [
                              Text(
                                index == 0
                                    ? '🥇'
                                    : index == 1
                                        ? '🥈'
                                        : index == 2
                                            ? '🥉'
                                            : '${index + 1}',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  scoreData.userName,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                '${scoreData.score} Poin',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFD5B71),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                );
              }

              return Center(
                child: Padding(
                  padding: EdgeInsets.only(top: topPad + appBarHeight),
                  child: const Text('Gagal memuat leaderboard.'),
                ),
              );
            },
          ),

          // CONFETTI
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: [Colors.red, Colors.blue, Colors.yellow, Colors.green],
            ),
          ),
        ],
      ),
    );
  }
}

/// ====== WIDGET: AppBar kaca ======
class _GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onBack;
  const _GlassAppBar({required this.title, required this.onBack});

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.only(top: top, left: 16, right: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            height: preferredSize.height - 8,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF9B5BFF).withOpacity(0.18),
                  Colors.white.withOpacity(0.12),
                  const Color(0xFF7C3AED).withOpacity(0.16),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.35), width: 1),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withOpacity(0.18),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  onPressed: onBack,
                ),
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 48), // spacer biar judul tetap center
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ====== WIDGET: Tile glass reusable ======
class _GlassTile extends StatelessWidget {
  final Widget child;
  const _GlassTile({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF9B5BFF).withOpacity(0.12),
                Colors.white.withOpacity(0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.28)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3AED).withOpacity(0.14),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// ====== PODIUM GLASS ======
class AnimatedPodium extends StatelessWidget {
  final List<dynamic> topThree;
  const AnimatedPodium({super.key, required this.topThree});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 🥈 Perak
          Expanded(
            child: _buildAnimatedBlock(
              rank: 2,
              height: 140,
              data: topThree.length > 1 ? topThree[1] : null,
              accent: const Color(0xFFC0C0C0), // silver
            ),
          ),
          // 🥇 Emas
          Expanded(
            child: _buildAnimatedBlock(
              rank: 1,
              height: 180,
              data: topThree.isNotEmpty ? topThree[0] : null,
              crown: true,
              accent: const Color(0xFFFFD700), // gold
            ),
          ),
          // 🥉 Perunggu
          Expanded(
            child: _buildAnimatedBlock(
              rank: 3,
              height: 120,
              data: topThree.length > 2 ? topThree[2] : null,
              accent: const Color(0xFFCD7F32), // bronze
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBlock({
    required int rank,
    required double height,
    required dynamic data,
    required Color accent, // ⬅️ warna aksen podium
    bool crown = false,
  }) {
    final medal = rank == 1 ? '🥇' : rank == 2 ? '🥈' : '🥉';

    return LayoutBuilder(
      builder: (context, constraints) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: height),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (crown) const Text('👑', style: TextStyle(fontSize: 24)),
                Text(medal, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 2),
                FittedBox(
                  child: Text(
                    data?.userName ?? '-',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  data != null ? '${data.score} Poin' : '-',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Color(0xFFFD5B71),
                  ),
                ),
                const SizedBox(height: 6),

                // ===== BAR PODIUM: GLASS + TINT SESUAI WARNA PERINGKAT =====
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      width: 64,
                      height: value,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            accent.withOpacity(0.26), // tint utama
                            Colors.white.withOpacity(0.10), // frosted layer
                            accent.withOpacity(0.22), // tint bayangan
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withOpacity(0.34), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withOpacity(0.22), // glow sesuai aksen
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Text(
                          '$rank',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // tetap kontras di atas kaca
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
