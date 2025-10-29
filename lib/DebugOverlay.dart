
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';

class DebugOverlay extends Component {
  final Vector2 position;
  final int maxLines;
  final double lineHeight;

  final List<TextComponent> _lines = [];

  DebugOverlay({
    this.position = const Vector2(10, 10),
    this.maxLines = 8,
    this.lineHeight = 18.0,
    int priority = 10000,
  }) : super(priority: priority);

  /// Muestra un nuevo mensaje. Uso: debugOverlay.show('Mi msg');
  void show(String text) {
    // crear TextComponent y añadirlo como hijo de este overlay
    final tc = TextComponent(
      text: text,
      position: Vector2(position.x, position.y + _lines.length * lineHeight),
      anchor: Anchor.topLeft,
    );

    _lines.add(tc);
    add(tc);

    // Si nos pasamos del máximo, eliminamos el primero y re-posicionamos.
    if (_lines.length > maxLines) {
      final removed = _lines.removeAt(0);
      removed.removeFromParent();
      _rebuildPositions();
    }
  }

  /// Borra todos los mensajes
  void clear() {
    for (final l in List<TextComponent>.from(_lines)) {
      l.removeFromParent();
    }
    _lines.clear();
  }

  void _rebuildPositions() {
    for (int i = 0; i < _lines.length; i++) {
      _lines[i].position = Vector2(position.x, position.y + i * lineHeight);
    }
  }
}