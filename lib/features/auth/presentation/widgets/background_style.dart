import 'dart:math';
import 'package:flutter/material.dart';
import 'package:revida/config/theme/app_colors.dart';

class BackgroundStyle extends StatefulWidget {
  final Widget content;
  const BackgroundStyle({super.key, required this.content});

  @override
  State<BackgroundStyle> createState() => _BackgroundStyleState();
}

class _BackgroundStyleState extends State<BackgroundStyle> {
  final List<String> assetImages = [
    'assets/background_draws/avion_papel.png',
    'assets/background_draws/botella_agua.png',
    'assets/background_draws/bolsa_basura.png',        
    'assets/background_draws/caja_carton.png',
    'assets/background_draws/cascara_banana.png',
    'assets/background_draws/manzana_mordida.png',
    'assets/background_draws/lata.png',
    'assets/background_draws/periodico.png',
    'assets/background_draws/simbolo_reciclaje.png',
    'assets/background_draws/bote_basura.png',
  ];

  List<_BackgroundItem> items = [];

  @override
  void initState() {
    super.initState();
    _generateRandomPositions();
  }

  void _generateRandomPositions() {
    final random = Random();
    items = assetImages.map((path) {
      return _BackgroundItem(
        assetPath: path,
        top: random.nextDouble(), 
        left: random.nextDouble(),
        rotation: random.nextDouble() * 2 * pi, 
        size: 40 + random.nextDouble() * 30, 
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // 1. FONDO ACTUALIZADO: Gris súper claro para dar un aspecto limpio
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          ...items.map((item) {
            return Positioned(
              top: item.top * size.height,
              left: item.left * size.width,
              child: Transform.rotate(
                angle: item.rotation,
                child: Opacity(
                  // 2. OPACIDAD REDUCIDA: De 0.8 a 0.25 para que sea "marca de agua"
                  opacity: 0.25, 
                  child: Image.asset(
                    item.assetPath,
                    width: item.size,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            );
          }),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 78),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.card(context),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          // 3. SOMBRA SUAVIZADA: Para que combine con el Home
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: widget.content,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundItem {
  final String assetPath;
  final double top;
  final double left;
  final double rotation;
  final double size;

  _BackgroundItem({
    required this.assetPath,
    required this.top,
    required this.left,
    required this.rotation,
    required this.size,
  });
}