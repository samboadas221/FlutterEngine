
// CustomList.dart
// API imperativa / estilo "objeto" (como tu CustomButton).
// - CustomList: objeto configurable con métodos como setLeftMargin, addItem, ...
// - CustomItem: item compuesto dividido horizontalmente en N secciones.
// - build() produce el Widget listo para insertar en tu CustomMenu.
//
// Integra SoundManager (usa SoundManager.playFastEffect) y acepta tu clase Button
// (la detecta y usa button.build()).

import 'package:flutter/material.dart';
import 'CustomButton.dart'; // tu clase Button
import 'SoundManager.dart';

/// Item compuesto que permite dividir horizontalmente en `n` celdas
/// y asignar contenido (Widget, Button o String) a cada celda.
/// También permite definir la proporción (porcentaje) de cada celda.
class CustomItem {
  final int _cells;
  final List<dynamic> _content; // Widget | Button | String | null
  final List<double> _spacePercents; // porcentajes (sumas serán normalizados)
  final Key? key;
  VoidCallback? onTap;
  VoidCallback? onLongPress;
  EdgeInsetsGeometry padding = const EdgeInsets.all(6);

  CustomItem({int cells = 1, this.key})
      : _cells = cells < 1 ? 1 : cells,
        _content = List<dynamic>.filled(cells < 1 ? 1 : cells, null, growable: false),
        _spacePercents = List<double>.filled(cells < 1 ? 1 : cells, 0.0, growable: false);

  /// Divide horizontalmente en n celdas (reinicializa contenidos y espacios)
  void splitHorizontal(int n) {
    final nn = (n < 1) ? 1 : n;
    _content
      ..clear()
      ..addAll(List<dynamic>.filled(nn, null));
    _spacePercents
      ..clear()
      ..addAll(List<double>.filled(nn, 0.0));
  }

  /// Setea contenido en la celda [index]. content puede ser String, Widget, Button.
  void set(int index, dynamic content) {
    if (index < 0 || index >= _content.length) return;
    _content[index] = content;
  }

  /// Setea contenido de forma secuencial (primera celda libre)
  void setContent(dynamic content) {
    final idx = _content.indexWhere((e) => e == null);
    if (idx == -1) return;
    _content[idx] = content;
  }

  /// Define cuanto espacio relativo ocupa la celda index (en porcentaje).
  /// Ej: setSpace(0, 10.0) -> 10% relativo (no necesita sumar 100).
  void setSpace(int index, double percent) {
    if (index < 0 || index >= _spacePercents.length) return;
    _spacePercents[index] = percent < 0 ? 0.0 : percent;
  }

  /// Obtiene la representación interna de cada celda
  List<dynamic> get _cellsContent => List.unmodifiable(_content);

  /// Calcula la lista de flex (int) a partir de porcentajes.
  /// Si todos son cero, cada celda recibe igual proporción.
  List<int> _computeFlexes() {
    final total = _spacePercents.fold<double>(0.0, (a, b) => a + (b.isFinite ? b : 0.0));
    if (total <= 0.0001) {
      // repartir equitativamente
      final equal = List<int>.filled(_content.length, 1);
      return equal;
    } else {
      // normalizar porcentajes a enteros (flex)
      final flexes = _spacePercents.map((p) => (p / total * 1000).round()).toList();
      // evitar ceros
      for (int i = 0; i < flexes.length; i++) {
        if (flexes[i] <= 0) flexes[i] = 1;
      }
      return flexes;
    }
  }
}

/// Clase principal: CustomList (API imperativa).
/// Crea una lista y permite configurarla mediante métodos style-API,
/// luego llamar `build()` para obtener el Widget que la renderiza.
class CustomList {
  // Configuración visual
  double _leftMargin = 0.0;
  double _rightMargin = 0.0;
  double _topMargin = 0.0;
  double _bottomMargin = 0.0;
  String? _headingText;
  bool _headingVisible = false;
  double _itemSeparation = 8.0;
  EdgeInsetsGeometry _itemPadding = const EdgeInsets.symmetric(vertical: 6, horizontal: 8);

  // Contenido: puede ser String, Widget, Button, CustomItem
  final List<dynamic> _items = [];

  // Click sound (asset path) reproducido cuando se pulsa el item (si configurado)
  String? _itemClickSoundAsset;

  // Scroll controller expuesto para control programático si lo deseas
  final ScrollController scrollController = ScrollController();

  // Opciones
  bool _shrinkWrap = false;
  Axis _direction = Axis.vertical;
  bool _showScrollbar = false;

  // Constructor simple
  CustomList();

  // -------------------------
  // API imperativa (mutadores)
  // -------------------------
  void setLeftMargin(double v) => _leftMargin = v;
  void setRightMargin(double v) => _rightMargin = v;
  void setTopMargin(double v) => _topMargin = v;
  void setBottomMargin(double v) => _bottomMargin = v;

  void setMargins({double? left, double? right, double? top, double? bottom}) {
    if (left != null) _leftMargin = left;
    if (right != null) _rightMargin = right;
    if (top != null) _topMargin = top;
    if (bottom != null) _bottomMargin = bottom;
  }

  void setHeadingText(String text) {
    _headingText = text;
    _headingVisible = true;
  }

  void removeHeading() {
    _headingVisible = false;
    _headingText = null;
  }

  void addHeading(String text) {
    setHeadingText(text);
  }

  void setItemSeparation(double s) {
    _itemSeparation = s;
  }

  void setItemPadding(EdgeInsetsGeometry p) {
    _itemPadding = p;
  }

  void setShrinkWrap(bool v) {
    _shrinkWrap = v;
  }

  void setDirection(Axis d) {
    _direction = d;
  }

  void showScrollbar(bool v) {
    _showScrollbar = v;
  }

  /// Reproduce un sonido cuando se pulsa un item (usa SoundManager.playFastEffect)
  void setClickSound(String assetPath) {
    _itemClickSoundAsset = assetPath;
  }

  /// Añade un item: puede ser String, Widget, Button o CustomItem
  void addItem(dynamic item) {
    if (item is String || item is Widget || item is Button || item is CustomItem) {
      _items.add(item);
    } else {
      // intenta aceptar mapas con forma [left, center, right] (comodidad)
      _items.add(item);
    }
  }

  /// Inserta item en posición
  void insertItem(int index, dynamic item) {
    if (index < 0) index = 0;
    if (index > _items.length) index = _items.length;
    _items.insert(index, item);
  }

  /// Remueve un item por índice
  void removeAt(int index) {
    if (index < 0 || index >= _items.length) return;
    _items.removeAt(index);
  }

  /// Reemplaza item en índice
  void setItem(int index, dynamic item) {
    if (index < 0 || index >= _items.length) return;
    _items[index] = item;
  }

  /// Limpia la lista
  void clear() {
    _items.clear();
  }

  /// Número de items
  int get length => _items.length;

  /// Obtiene copia inmutable de items
  List<dynamic> get items => List.unmodifiable(_items);

  // -------------------------
  // Render: build() -> Widget
  // -------------------------
  /// Devuelve el Widget que renderiza la lista, para insertar en tu CustomMenu:
  /// Por ejemplo: menu.add(myList.build());
  Widget build() {
    final EdgeInsets outer = EdgeInsets.fromLTRB(_leftMargin, _topMargin, _rightMargin, _bottomMargin);

    Widget listView = _CustomListWidget(
      config: _CustomListConfig(
        headingText: _headingText,
        headingVisible: _headingVisible,
        itemSeparation: _itemSeparation,
        itemPadding: _itemPadding,
        items: _items,
        itemClickSoundAsset: _itemClickSoundAsset,
        scrollController: scrollController,
        shrinkWrap: _shrinkWrap,
        direction: _direction,
      ),
      showScrollbar: _showScrollbar,
    );

    return Padding(padding: outer, child: listView);
  }
}

// ------------------
// Internals: config & widget
// ------------------

class _CustomListConfig {
  final String? headingText;
  final bool headingVisible;
  final double itemSeparation;
  final EdgeInsetsGeometry itemPadding;
  final List<dynamic> items;
  final String? itemClickSoundAsset;
  final ScrollController scrollController;
  final bool shrinkWrap;
  final Axis direction;

  _CustomListConfig({
    this.headingText,
    required this.headingVisible,
    required this.itemSeparation,
    required this.itemPadding,
    required this.items,
    required this.itemClickSoundAsset,
    required this.scrollController,
    required this.shrinkWrap,
    required this.direction,
  });
}

class _CustomListWidget extends StatefulWidget {
  final _CustomListConfig config;
  final bool showScrollbar;

  const _CustomListWidget({Key? key, required this.config, this.showScrollbar = false}) : super(key: key);

  @override
  State<_CustomListWidget> createState() => _CustomListWidgetState();
}

class _CustomListWidgetState extends State<_CustomListWidget> {
  @override
  void initState() {
    super.initState();
  }

  Widget _buildSimpleString(String s) {
    return Padding(
      padding: widget.config.itemPadding,
      child: Text(s, style: const TextStyle(fontSize: 16)),
    );
  }

  Widget _buildButtonItem(Button b) {
    try {
      return b.build(); // usa el patrón de tu CustomButton
    } catch (e) {
      // Fallback simple
      return Padding(padding: widget.config.itemPadding, child: Text(b.toString()));
    }
  }

  Widget _buildCustomItem(CustomItem ci, int index) {
    final content = ci._cellsContent; // contenido por celda
    final flexes = ci._computeFlexes();
    final List<Widget> children = [];

    for (int i = 0; i < content.length; i++) {
      final c = content[i];
      Widget built;
      if (c == null) {
        built = const SizedBox.shrink();
      } else if (c is String) {
        built = Align(
          alignment: Alignment.centerLeft,
          child: Text(c, maxLines: 3, overflow: TextOverflow.ellipsis),
        );
      } else if (c is Button) {
        built = c.build();
      } else if (c is Widget) {
        built = c;
      } else {
        // unknown -> fallback to toString
        built = Text(c.toString());
      }

      // wrap with padding of the cell
      final wrapped = Padding(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4), child: built);
      children.add(Expanded(flex: flexes[i], child: wrapped));
    }

    Widget row = Row(children: children);

    // apply item padding & key if provided
    return Container(
      key: ci.key,
      padding: ci.padding,
      child: row,
    );
  }

  Widget _wrapItemTap(Widget child, dynamic rawItem, int index) {
    // detect callbacks present on CustomItem
    VoidCallback? onTap;
    VoidCallback? onLongPress;
    if (rawItem is CustomItem) {
      onTap = rawItem.onTap;
      onLongPress = rawItem.onLongPress;
    }

    return InkWell(
      onTap: () async {
        // play click sound if configured
        if (widget.config.itemClickSoundAsset != null) {
          try {
            SoundManager.playFastEffect(widget.config.itemClickSoundAsset!);
          } catch (_) {}
        }
        // then call item's onTap if present
        onTap?.call();
      },
      onLongPress: onLongPress,
      child: child,
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    final raw = widget.config.items[index];
    Widget itemWidget;

    if (raw is String) {
      itemWidget = _buildSimpleString(raw);
    } else if (raw is Button) {
      itemWidget = _buildButtonItem(raw);
    } else if (raw is CustomItem) {
      itemWidget = _buildCustomItem(raw, index);
    } else if (raw is Widget) {
      itemWidget = raw;
    } else {
      // If user passed a List/Map shorthand, try to build a 3-part CustomItem
      if (raw is List && raw.isNotEmpty) {
        final ci = CustomItem(cells: raw.length);
        for (int i = 0; i < raw.length && i < ci._cellsContent.length; i++) {
          ci.set(i, raw[i]);
        }
        itemWidget = _buildCustomItem(ci, index);
      } else {
        itemWidget = Padding(padding: widget.config.itemPadding, child: Text(raw?.toString() ?? ""));
      }
    }

    final padded = Padding(
      padding: widget.config.itemPadding,
      child: itemWidget,
    );

    // Ensure each item has a Key to avoid rebuild problems
    final key = (raw is CustomItem && raw.key != null) ? raw.key : ValueKey('custom_list_item_$index');

    final decorated = Container(
      key: key,
      margin: EdgeInsets.symmetric(vertical: widget.config.itemSeparation / 2),
      child: padded,
    );

    return _wrapItemTap(decorated, raw, index);
  }

  @override
  Widget build(BuildContext context) {
    final cfg = widget.config;

    Widget list = ListView.builder(
      controller: cfg.scrollController,
      scrollDirection: cfg.direction,
      padding: EdgeInsets.zero,
      shrinkWrap: cfg.shrinkWrap,
      itemCount: cfg.items.length + (cfg.headingVisible ? 1 : 0),
      itemBuilder: (context, i) {
        if (cfg.headingVisible) {
          if (i == 0) {
            // heading
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 6.0),
              child: Text(cfg.headingText ?? "", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            );
          } else {
            return _buildItem(context, i - 1);
          }
        } else {
          return _buildItem(context, i);
        }
      },
    );

    if (widget.showScrollbar) {
      return Scrollbar(controller: cfg.scrollController, thumbVisibility: true, child: list);
    }

    return list;
  }
}