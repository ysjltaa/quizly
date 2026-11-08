import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import '../theme/theme_controller.dart';

/// Gambar background tiap tema, urutannya sama dengan daftar `palettes`
/// (Ocean, Campfire, Mars Escape, Forest, Sneaky Cat).
const List<String> _themeImages = [
  'assets/images/themes/ocean.jpeg',
  'assets/images/themes/campfire.jpeg',
  'assets/images/themes/mars.jpeg',
  'assets/images/themes/forest.jpeg',
  'assets/images/themes/cat.jpeg',
];

// Tingkat blur (makin besar makin buram) dan gelap overlay
const double _blurSigma = 2.5;
const double _overlayOpacity = 0.30;

Future<void> showThemePicker(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => const _ThemePickerSheet(),
  );
}

class _ThemePickerSheet extends StatelessWidget {
  const _ThemePickerSheet();

  @override
  Widget build(BuildContext context) {
    final ctrl = ThemeController.instance;
    return ListenableBuilder(
      listenable: ctrl,
      builder: (_, __) => SafeArea(
        child: ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          itemCount: palettes.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final p = palettes[i];
            final selected = ctrl.paletteIndex == i;
            final image = i < _themeImages.length ? _themeImages[i] : null;

            return GestureDetector(
              onTap: () => ctrl.setPalette(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                      color: selected ? Colors.white : Colors.transparent,
                      width: 3),
                  boxShadow: [
                    BoxShadow(
                        color: p.gradient.last.withOpacity(selected ? .5 : .2),
                        blurRadius: selected ? 14 : 6,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Lapisan dasar: gradien (juga jadi cadangan kalau gambar tidak ada)
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: p.gradient),
                        ),
                      ),

                      // Gambar + blur ringan
                      if (image != null)
                        ImageFiltered(
                          imageFilter: ImageFilter.blur(
                              sigmaX: _blurSigma,
                              sigmaY: _blurSigma,
                              tileMode: TileMode.clamp),
                          child: Transform.scale(
                            scale: 1.08, // menutup tepi yang memudar karena blur
                            child: Image.asset(
                              image,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                              const SizedBox.shrink(),
                            ),
                          ),
                        ),

                      // Overlay gelap supaya tulisan tetap terbaca
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.black.withOpacity(_overlayOpacity + 0.15),
                              Colors.black.withOpacity(_overlayOpacity - 0.1),
                            ],
                          ),
                        ),
                      ),

                      // Isi kartu
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(p.icon, color: Colors.white, size: 36),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                p.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  shadows: [
                                    Shadow(
                                        color: Colors.black54,
                                        blurRadius: 6,
                                        offset: Offset(0, 1)),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                  color: selected ? Colors.green : Colors.white,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Text(selected ? 'Selected' : 'Choose',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: selected
                                          ? Colors.white
                                          : Colors.black87)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}