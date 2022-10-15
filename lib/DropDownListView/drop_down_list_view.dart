import 'dart:async';

import 'package:flutter/material.dart';
import 'package:menu_items/DropDownListView/drop_down_overlay.dart';

typedef MenuItemBuilder = Widget Function(String data, int index);
typedef OnValueChanged = dynamic Function(String data, int index);
typedef OnWidgetTransition = Widget? Function(double animationValue);
typedef DropdownButtonWidgetBuilder = Widget Function(BuildContext context, int selectedIndex);
typedef DropdownItemWidgetBuilder = Widget Function(BuildContext context, String value, int index, bool selected);


class DropDownListView extends StatefulWidget {
  DropDownListView({
    Key? key,
    this.menuItemBuilder,
    this.gaps = 10,
    required this.onValueChanged,
    required this.items,
    this.curve = Curves.easeInOutCubic,
    this.physics,
    this.duration = 250,
    this.elevation = 5,
    this.selectedValue,
    this.onWidgetTransition,
    this.defaultItemIndex = 0,
    this.hint,
    this.iconData = Icons.arrow_drop_down,
    required this.dropdownButtonBuilder,
    required this.dropdownItemBuilder,
  }) : super(key: key);

  double gaps;
  double elevation;
  MenuItemBuilder? menuItemBuilder;
  OnValueChanged onValueChanged;
  Curve curve;
  int duration;
  String? selectedValue;
  List<String> items;
  String? hint;
  ScrollPhysics? physics;
  OnWidgetTransition? onWidgetTransition;
  int defaultItemIndex;
  IconData iconData;
  VoidCallback? onMenuOpen;
  VoidCallback? onMenuClose;
  DropdownButtonWidgetBuilder dropdownButtonBuilder;
  DropdownItemWidgetBuilder dropdownItemBuilder;

  @override
  _DropDownListViewState createState() => _DropDownListViewState();
}

class _DropDownListViewState extends State<DropDownListView>
    with SingleTickerProviderStateMixin {
  final GlobalKey _mainWidgetKey = GlobalKey();
  late final ValueNotifier<int> _valueNotifier;
  final LayerLink _layerLink = LayerLink();

  OverlayEntry? _floatingDropDownOverlayEntry;
  Offset btnOffset = Offset.zero;
  Size btnDimension = Size.zero;
  bool _isExpanded = false;
  String selectedValue = 'Selected';
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    assert(widget.items.length > widget.defaultItemIndex,
        "Default Item Index must not larger then total items");
    _valueNotifier = ValueNotifier(widget.defaultItemIndex);
    selectedIndex = widget.defaultItemIndex;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: RawMaterialButton(
        key: _mainWidgetKey,
        onPressed: () => _isExpanded ? _closeMenu() : _openMenu(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ValueListenableBuilder(
              valueListenable: _valueNotifier,
              builder: (context, int index, child) {
                return widget.dropdownButtonBuilder(context, index);
              },
            ),
            const SizedBox(width: 10),
            Icon(widget.iconData),
          ],
        ),
      ),
    );
  }

  OverlayEntry _createFloatingDropDown() {
    Size size = MediaQuery.of(context).size;
    return OverlayEntry(
      builder: (context) {
        return DropDownOverlay(
          btnOffset: btnOffset,
          btnDimension: btnDimension,
          constraintSize: size,
          layerLink: _layerLink,
          physics: widget.physics ?? const ClampingScrollPhysics(),
          elevation: widget.elevation,
          gaps: widget.gaps,
          dropdownItemBuilder: widget.dropdownItemBuilder,
          items: widget.items,
          onClose: _closeMenu,
          onValueChanged: _onPress,
          selectedIndex: _valueNotifier.value,
        );
      },
    );
  }

  _findDropDownPosition() {
    RenderBox renderBox =
        _mainWidgetKey.currentContext!.findRenderObject() as RenderBox;
    btnDimension = renderBox.size;
    btnOffset = renderBox.localToGlobal(Offset.zero);
    // debugPrint("x: $_x, y: $_y, height: $btnDimension.height, width: $btnDimension.width");
  }

  _openMenu() async {
    if (!_isExpanded) {
      FocusScopeNode currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
      OverlayState overlayState = Overlay.of(context)!;
      _findDropDownPosition();
      _floatingDropDownOverlayEntry = _createFloatingDropDown();
      overlayState.insert(_floatingDropDownOverlayEntry!);
      _isExpanded = true;
      if (widget.onMenuOpen != null) widget.onMenuOpen!();
    }
  }

  _closeMenu() async {
    if (_isExpanded) {
      _floatingDropDownOverlayEntry!.remove();
      _isExpanded = false;
      if (widget.onMenuClose != null) widget.onMenuClose!();
    }
  }

  _onPress(String value, int index) {
    _valueNotifier.value = index;
    _closeMenu();
    widget.onValueChanged(value, index);
  }

  @override
  void dispose() async {
    super.dispose();
    _valueNotifier.dispose();
    if (_floatingDropDownOverlayEntry != null)
      _floatingDropDownOverlayEntry!.dispose();
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
