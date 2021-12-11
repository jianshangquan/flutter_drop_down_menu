import 'dart:async';

import 'package:flutter/material.dart';

import 'drop_down_list_item.dart';
import 'drop_down_list_position.dart';
import 'package:collection/collection.dart';

typedef MenuItemBuilder = Widget Function(String data, int index);
typedef OnValueChanged = dynamic Function(String data, int index);
typedef OnWidgetTransition = Widget? Function(double animationValue);
typedef DropdownButtonWidgetBuilder = Widget Function(
    BuildContext context, String selectedValue);
typedef DropdownItemWidgetBuilder = Widget Function(
    BuildContext context, String value);

class DropDownListView extends StatefulWidget {
  DropDownListView({
    Key? key,
    this.menuItemBuilder,
    this.height = 300,
    this.itemHeight = 30,
    this.gaps = 10,
    required this.onValueChanged,
    required this.items,
    this.curve = Curves.easeInOutCubic,
    this.position = DropdownPosition.bottom,
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

  double height;
  double itemHeight;
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
  DropdownPosition position;
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
  late final AnimationController _animationController;
  late final Animation<double> _animation;
  late final ValueNotifier<String> _valueNotifier;
  final LayerLink _layerLink = LayerLink();

  OverlayEntry? _floatingDropDownOverlayEntry;
  double _x = 0, _y = 0, _height = 0, _width = 0;
  bool _isExpanded = false;
  String selectedValue = 'Selected';

  @override
  void initState() {
    super.initState();
    assert(widget.items.length > widget.defaultItemIndex,
        "Default Item Index must not larger then total items");
    _valueNotifier =
        ValueNotifier(widget.hint ?? widget.items[widget.defaultItemIndex]);
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: widget.duration));
    _animation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animationController, curve: widget.curve));
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
              builder: (context, String value, child) {
                return widget.dropdownButtonBuilder(context, value);
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
    double floatingTop = 0;
    double floatingLeft = 0;
    switch (widget.position) {
      case DropdownPosition.bottom:
        {
          floatingTop = _height + widget.gaps;
        }
        break;
      case DropdownPosition.top:
        {
          floatingTop = -widget.height - widget.gaps;
        }
        break;
      case DropdownPosition.rightTop:
        {
          floatingTop = -widget.height - widget.gaps + _height;
          floatingLeft = _width;
        }
        break;
      case DropdownPosition.rightBottom:
        {
          floatingTop = 0;
          floatingLeft = _width + widget.gaps;
        }
        break;
      case DropdownPosition.leftTop:
        {
          floatingTop = -widget.height - widget.gaps + _height;
          floatingLeft = -_width - widget.gaps;
        }
        break;
      case DropdownPosition.leftBottom:
        {
          floatingTop = 0;
          floatingLeft = -_width - widget.gaps;
        }
        break;
      case DropdownPosition.automatic:
        // TODO: Handle this case.
        break;
    }
    return OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            SizedBox(
              width: size.width,
              height: size.height,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _closeMenu,
              ),
            ),
            Positioned(
              left: _x,
              top: _y + _height + _height + widget.gaps,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(
                    floatingLeft,
                    (widget.position == DropdownPosition.top ||
                            widget.position == DropdownPosition.rightTop ||
                            widget.position == DropdownPosition.leftTop)
                        ? floatingTop * _animation.value
                        : floatingTop),
                child: Opacity(
                  opacity: _animation.value,
                  child: Container(
                    width: _width,
                    height: widget.height * _animation.value,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(10 * _animation.value),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color:
                              Colors.black.withOpacity(0.2 * _animation.value),
                          blurRadius: widget.elevation * _animation.value,
                          spreadRadius: 0.0,
                          offset: const Offset(
                              2, 2), // shadow direction: bottom right
                        )
                      ],
                    ),
                    child: ScrollConfiguration(
                      behavior: MyBehavior(),
                      child: SingleChildScrollView(
                        physics:
                            widget.physics ?? const ClampingScrollPhysics(),
                        child: Material(
                          color: Colors.transparent,
                          child: Column(
                            children: widget.items.mapIndexed((index, item) {
                              return DropDownItem(
                                value: item,
                                builder: (context, label) {
                                  return SizedBox(
                                    width: double.infinity,
                                    height: widget.itemHeight,
                                    child: widget.dropdownItemBuilder(
                                      context,
                                      label,
                                    ),
                                  );
                                },
                                onPressed: () => _onPress(item, index),
                              );
                            }).toList(),
                          ),
                        ),
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
  }

  _findDropDownPosition() {
    RenderBox renderBox =
        _mainWidgetKey.currentContext!.findRenderObject() as RenderBox;
    _height = renderBox.size.height;
    _width = renderBox.size.width;
    Offset offset = renderBox.localToGlobal(Offset.zero);
    _x = offset.dx;
    _y = offset.dy;
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
      Overlay.of(context)?.insert(_floatingDropDownOverlayEntry!);
      _animationController.addListener(() {
        overlayState.setState(() {});
        if (widget.onWidgetTransition != null)
          widget.onWidgetTransition!(_animationController.value);
      });
      await _animationController.forward();
      _isExpanded = true;
      if (widget.onMenuOpen != null) widget.onMenuOpen!();
    }
  }

  _closeMenu() async {
    if (_isExpanded) {
      await _animationController.reverse();
      _floatingDropDownOverlayEntry!.remove();
      _isExpanded = false;
      if (widget.onMenuClose != null) widget.onMenuClose!();
    }
  }

  _onPress(String value, int index) {
    _valueNotifier.value = value;
    _closeMenu();
    widget.onValueChanged(value, index);
  }

  @override
  void dispose() async {
    // await _closeMenu();
    super.dispose();
    _valueNotifier.dispose();
    _animationController.dispose();
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
