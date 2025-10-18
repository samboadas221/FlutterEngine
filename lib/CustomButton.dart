
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

/// Un botón completamente personalizable, con una API sencilla estilo OOP.
/// Ahora con soporte para reproducir un sonido al hacer click:
///   button.setAudioOnClick("assets/audio/click8.wav");
class Button {
  String _text = "Button";
  Color _backgroundColor = Colors.blue;
  Color _textColor = Colors.white;
  double _fontSize = 18.0;
  EdgeInsets _padding = const EdgeInsets.symmetric(horizontal: 40, vertical: 20);
  VoidCallback? _onPressed;
  String? _clickAudioAsset; // ruta del asset (normalizada)

  // --------------------------
  // API simple que pediste
  // --------------------------
  void setText(String text) => _text = text;
  void setBackgroundColor(Color color) => _backgroundColor = color;
  void setTextColor(Color color) => _textColor = color;
  void setFontSize(double size) => _fontSize = size;
  void setPadding(EdgeInsets padding) => _padding = padding;
  void setOnPressed(VoidCallback callback) => _onPressed = callback;

  /// Asigna un asset de audio para reproducir al hacer click.
  /// Acepta rutas como "assets/audio/click.wav" o "audio/click.wav".
  void setAudioOnClick(String assetPath) {
    _clickAudioAsset = _normalizeAssetPath(assetPath);
  }

  // Normalize para AssetSource: remove leading "assets/" si viene
  static String _normalizeAssetPath(String p) {
    if (p.startsWith('assets/')) p = p.substring(7);
    if (p.startsWith('/')) p = p.substring(1);
    return p;
  }

  /// Devuelve el Widget de Flutter listo para usarse
  Widget build() {
    return _CustomButtonWidget(
      text: _text,
      backgroundColor: _backgroundColor,
      textColor: _textColor,
      fontSize: _fontSize,
      padding: _padding,
      onPressed: _onPressed,
      clickAudioAsset: _clickAudioAsset,
    );
  }
}

// ----------------------------------------------------
// Widget interno que maneja el estado del botón
// ----------------------------------------------------
class _CustomButtonWidget extends StatefulWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final EdgeInsets padding;
  final VoidCallback? onPressed;
  final String? clickAudioAsset;

  const _CustomButtonWidget({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.fontSize,
    required this.padding,
    required this.onPressed,
    required this.clickAudioAsset,
    Key? key,
  }) : super(key: key);

  @override
  State<_CustomButtonWidget> createState() => _CustomButtonWidgetState();
}

class _CustomButtonWidgetState extends State<_CustomButtonWidget> {
  bool _isPressed = false;

  // Reproduce el sonido (no bloqueante). Creamos un AudioPlayer en modo lowLatency.
  Future<void> _playClickSound(String assetPath) async {
    try {
      final player = AudioPlayer();
      await player.setReleaseMode(ReleaseMode.stop);
      await player.play(AssetSource(assetPath));
      player.dispose();
    } catch (e) {
      // Si falla la reproducción no hacemos nada (no rompe la UI).
      // Puedes agregar logging si quieres.
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) async {
        setState(() => _isPressed = false);
        // Primero reproducimos el sonido (fire-and-forget)
        if (widget.clickAudioAsset != null) {
          _playClickSound(widget.clickAudioAsset!);
        }
        // Luego llamamos al callback del usuario
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: widget.padding,
        decoration: BoxDecoration(
          color: _isPressed
              ? widget.backgroundColor.withOpacity(0.7)
              : widget.backgroundColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: widget.backgroundColor.withOpacity(0.4),
                    offset: const Offset(0, 4),
                    blurRadius: 6,
                  ),
                ],
        ),
        child: Text(
          widget.text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: widget.textColor,
            fontSize: widget.fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}