

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'SoundManager.dart';

// Un botón completamente personalizable, con API simple.
// Permite sonido, color, texto, ancho fijo, etc.
class Button {
  String _text = "Button";
  Color _backgroundColor = Colors.blue;
  Color _textColor = Colors.white;
  double _fontSize = 18.0;
  EdgeInsets _padding = const EdgeInsets.symmetric(horizontal: 40, vertical: 20);
  VoidCallback? _onPressed;
  String? _clickAudioAsset;

  // Control de ancho
  double? _fixedWidth; // null => auto
  bool _centered = true;

  // --------------------------
  // API pública (estilo OOP)
  // --------------------------
  void setText(String text) => _text = text;
  void setBackgroundColor(Color color) => _backgroundColor = color;
  void setTextColor(Color color) => _textColor = color;
  void setFontSize(double size) => _fontSize = size;
  void setPadding(EdgeInsets padding) => _padding = padding;
  void setOnPressed(VoidCallback callback) => _onPressed = callback;

  void setAudioOnClick(String assetPath) {
    _clickAudioAsset = _normalizeAssetPath(assetPath);
  }

  void setFixedWidth(double w) => _fixedWidth = w;
  void setWidthAuto() => _fixedWidth = null;
  void setCenteredText(bool centered) => _centered = centered;
  
  String getText() => _text;
  double getFontSize() => _fontSize;
  EdgeInsets getPadding() => _padding;

  static String _normalizeAssetPath(String p) {
    if (p.startsWith('assets/')) p = p.substring(7);
    if (p.startsWith('/')) p = p.substring(1);
    return p;
  }

  Widget build() {
    return _CustomButtonWidget(
      text: _text,
      backgroundColor: _backgroundColor,
      textColor: _textColor,
      fontSize: _fontSize,
      padding: _padding,
      onPressed: _onPressed,
      clickAudioAsset: _clickAudioAsset,
      fixedWidth: _fixedWidth,
      centered: _centered,
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
  final double? fixedWidth;
  final bool centered;

  const _CustomButtonWidget({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.fontSize,
    required this.padding,
    required this.onPressed,
    required this.clickAudioAsset,
    this.fixedWidth,
    this.centered = true,
    Key? key,
  }) : super(key: key);

  @override
  State<_CustomButtonWidget> createState() => _CustomButtonWidgetState();
}

class _CustomButtonWidgetState extends State<_CustomButtonWidget> {
  
  bool _isPressed = false;
  
  
  Future<void> _playClickSound(String assetPath) async {
    try {
      SoundManager.playFastEffect(assetPath);
    } catch (e) {
      // Nothing
    }
  }
  
  @override
  Widget build(BuildContext context) {
    Widget animated = AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      margin: const EdgeInsets.symmetric(vertical: 8), // separación entre botones
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
        textAlign: widget.centered ? TextAlign.center : TextAlign.left,
        style: TextStyle(
          color: widget.textColor,
          fontSize: widget.fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    // Si hay ancho fijo, envolver en SizedBox
    if (widget.fixedWidth != null) {
      animated = SizedBox(width: widget.fixedWidth, child: animated);
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) async {
        setState(() => _isPressed = false);
        if (widget.clickAudioAsset != null) {
          _playClickSound(widget.clickAudioAsset!);
        }
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: animated,
    );
  }
}

