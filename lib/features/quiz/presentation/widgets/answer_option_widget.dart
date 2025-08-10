import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sundaart_sense/features/quiz/logic/quiz_bloc/quiz_bloc.dart';

class AnswerOption extends StatelessWidget {
  final String optionText;
  final int index;
  final QuizState currentState;
  final VoidCallback onTap;

  // properti state visual
  final bool isSelected;   // apakah user memilih opsi ini
  final bool isCorrect;    // apakah opsi ini jawaban benar
  final bool showResult;   // true saat status answered (tampilkan benar/salah)

  const AnswerOption({
    super.key,
    required this.optionText,
    required this.index,
    required this.currentState,
    required this.onTap,
    this.isSelected = false,
    this.isCorrect = false,
    this.showResult = false,
  });

  @override
  Widget build(BuildContext context) {
    final _Visual visual = _visualState(
      isSelected: isSelected,
      isCorrect: isCorrect,
      showResult: showResult,
    );

    return Opacity(
      opacity: visual.dimmed ? 0.9 : 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: InkWell(
            onTap: showResult ? null : onTap, // disable tap saat hasil ditampilkan
            splashColor: visual.baseColor.withOpacity(0.20),
            highlightColor: Colors.white.withOpacity(0.06),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    visual.baseColor.withOpacity(visual.fillOpacity1), // tint
                    Colors.white.withOpacity(visual.fillOpacity2),     // frosted
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: visual.borderColor,
                  width: visual.borderWidth,
                ),
                boxShadow: visual.shadow,
              ),
              child: Row(
                children: [
                  _IndexBadge(
                    index: index,
                    color: visual.badgeColor,
                    textColor: visual.badgeText,
                    borderColor: visual.badgeBorder,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      optionText,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                        color: visual.textColor,
                      ),
                    ),
                  ),
                  if (visual.trailing != null) ...[
                    const SizedBox(width: 10),
                    visual.trailing!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _Visual _visualState({
    required bool isSelected,
    required bool isCorrect,
    required bool showResult,
  }) {
    // Palet warna
    const purple = Color(0xFF8A4DFF);
    const textDark = Color(0xFF1F2937);

    if (!showResult) {
      // FASE MEMILIH: hanya highlight ungu untuk opsi terpilih
      if (isSelected) {
        return _Visual(
          baseColor: purple,
          borderColor: purple.withOpacity(0.85),
          borderWidth: 1.4,
          textColor: textDark,
          badgeColor: purple.withOpacity(0.20),
          badgeText: textDark,
          badgeBorder: Colors.white.withOpacity(0.30),
          fillOpacity1: 0.16,
          fillOpacity2: 0.10,
          trailing: const Icon(Icons.radio_button_checked, color: purple),
          shadow: [
            BoxShadow(
              color: purple.withOpacity(0.18),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        );
      }
      // default glass
      return _Visual(
        baseColor: purple,
        borderColor: Colors.white.withOpacity(0.28),
        borderWidth: 1.0,
        textColor: textDark,
        badgeColor: purple.withOpacity(0.14),
        badgeText: textDark,
        badgeBorder: Colors.white.withOpacity(0.28),
        fillOpacity1: 0.12,
        fillOpacity2: 0.08,
      );
    }

    // FASE HASIL: tampilkan benar/salah
    if (isCorrect) {
      return _Visual(
        // ⬇️ tint tetap ungu (bukan hijau), jadi yang hijau hanya BORDER
        baseColor: purple,
        borderColor: const Color(0xFF16A34A).withOpacity(0.95), // hijau tegas di tepi
        borderWidth: 1.8,
        textColor: textDark,

        // badge tetap netral/ungu
        badgeColor: purple.withOpacity(0.14),
        badgeText: textDark,
        badgeBorder: Colors.white.withOpacity(0.30),

        // ⬇️ fill glass netral (bukan hijau)
        fillOpacity1: 0.12, // ungu tipis
        fillOpacity2: 0.08, // frosted putih tipis

        // ikon cek netral (bukan hijau). Kalau mau hijau lagi, ganti ke Color(0xFF16A34A)
        trailing: const Icon(Icons.check_circle, color: textDark),

        // shadow sangat halus (bukan hijau)
        shadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      );
    }

    if (isSelected && !isCorrect) {
      return _Visual(
        baseColor: purple,       
        borderColor: const Color(0xFFDC2626).withOpacity(0.95), // tepi merah tegas
        borderWidth: 1.8,
        textColor: textDark,
        badgeColor: purple.withOpacity(0.14),
        badgeText: textDark,
        badgeBorder: Colors.white.withOpacity(0.30),
        fillOpacity1: 0.12, // ungu tipis
        fillOpacity2: 0.08, // frosted putih tipis
        trailing: const Icon(Icons.cancel, color: textDark), // ikon netral
        shadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      );
    }

    // Opsi lain (bukan benar, bukan yang dipilih)
    return _Visual(
      baseColor: purple,
      borderColor: Colors.white.withOpacity(0.24),
      borderWidth: 1.0,
      textColor: textDark,
      badgeColor: purple.withOpacity(0.10),
      badgeText: textDark,
      badgeBorder: Colors.white.withOpacity(0.26),
      fillOpacity1: 0.10,
      fillOpacity2: 0.08,
      dimmed: true,
    );
  }
}

class _IndexBadge extends StatelessWidget {
  final int index;
  final Color color;
  final Color textColor;
  final Color borderColor;
  const _IndexBadge({
    required this.index,
    required this.color,
    required this.textColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final letter = String.fromCharCode(65 + index); // 0->A, 1->B, ...
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            color,
            Colors.white.withOpacity(0.10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        letter,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}

class _Visual {
  final Color baseColor;      // warna aksen (ungu/hijau/merah)
  final Color borderColor;
  final double borderWidth;
  final Color textColor;
  final Color badgeColor;
  final Color badgeText;
  final Color badgeBorder;
  final double fillOpacity1;  // opasitas layer tint
  final double fillOpacity2;  // opasitas layer frosted
  final bool dimmed;          // sedikit redup jika bukan fokus
  final List<BoxShadow>? shadow;
  final Widget? trailing;     // ikon ✔ / ✖ / radio

  _Visual({
    required this.baseColor,
    required this.borderColor,
    required this.borderWidth,
    required this.textColor,
    required this.badgeColor,
    required this.badgeText,
    required this.badgeBorder,
    required this.fillOpacity1,
    required this.fillOpacity2,
    this.dimmed = false,
    this.shadow,
    this.trailing,
  });
}
