
import 'package:flutter/material.dart';
import 'CustomButton.dart';

/// Gestor global de menús.
/// Mantiene una lista de todos los menús y controla cuál está visible.
class MenuManager {
  static final List<Menu> _menus = [];
  static Menu? _currentMenu;

  static void register(Menu menu) {
    if (!_menus.contains(menu)) {
      _menus.add(menu);
    }
  }

  static void show(Menu menu) {
    for (var m in _menus) {
      m._visible = false;
    }
    menu._visible = true;
    _currentMenu = menu;
    _notifyAll();
  }

  static void _notifyAll() {
    for (var m in _menus) {
      m._update?.call();
    }
  }

  static Widget buildMenusLayer() {
    // Muestra todos los menús registrados, pero solo el activo será visible
    return Stack(
      children: _menus.map((m) => m._buildInternal()).toList(),
    );
  }
}

/// Clase Menu — contenedor simple de widgets (botones u otros).
class Menu {
  final List<dynamic> _children = [];
  bool _visible = false;
  VoidCallback? _update;
  final String name;

  Menu({this.name = "Menu"}) {
    MenuManager.register(this);
  }

  void setAsDefaultMenu() {
    MenuManager.show(this);
  }
  
  void matchButtonWidths() {
    double maxWidth = 0.0;
    for (var item in _children) {
      if (item is Button) {
        final text = item.getText();
        final fontSize = item.getFontSize();
        final padding = item.getPadding();

        final TextPainter tp = TextPainter(
          text: TextSpan(text: text, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold)),
          textDirection: TextDirection.ltr,
        )..layout();

        final double estimated = tp.width + padding.horizontal;
        if (estimated > maxWidth) maxWidth = estimated + 2;
      }
    }

    if (maxWidth > 0) {
      for (var item in _children) {
        if (item is Button) {
          item.setFixedWidth(maxWidth);
        }
      }
      _update?.call();
    }
  }
  
  void add(dynamic widget) {
    if (widget is Button) {
      _children.add(widget);
    } else if (widget is Widget) {
      _children.add(widget);
    } else {
      throw ArgumentError("Solo se pueden agregar Widgets o Buttons personalizados");
    }
    _update?.call();
  }

  void show() => MenuManager.show(this);
  void hide() {
    _visible = false;
    _update?.call();
  }

  Widget _buildInternal() {
    return _MenuWidget(menu: this);
  }
}

/// Widget interno que representa el menú en pantalla.
/// Muestra/oculta según el flag [_visible].
class _MenuWidget extends StatefulWidget {
  final Menu menu;
  const _MenuWidget({required this.menu});

  @override
  State<_MenuWidget> createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<_MenuWidget> {
  @override
  void initState() {
    super.initState();
    widget.menu._update = () => setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.menu._visible) {
      return const SizedBox.shrink();
    }

    List<Widget> widgets = widget.menu._children.map<Widget>((item) {
      if (item is Button) {
        return item.build();
      } else if (item is Widget) {
        return item;
      } else {
        return const SizedBox.shrink();
      }
    }).toList();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: widgets,
      ),
    );
  }
  
}