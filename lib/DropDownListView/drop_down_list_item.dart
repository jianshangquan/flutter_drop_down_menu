import 'dart:math';

import 'package:flutter/material.dart';

import 'drop_down_list_view.dart';


class DropDownItem extends StatefulWidget {
  String value;
  VoidCallback? onPressed;
  DropdownItemWidgetBuilder builder;
  int index, selectedIndex;

  DropDownItem({
    Key? key,
    required this.value,
    required this.onPressed,
    required this.builder,
    required this.index,
    required this.selectedIndex,
  }) : super(key: key);

  @override
  State<DropDownItem> createState() => _DropDownItemState();
}

class _DropDownItemState extends State<DropDownItem> with TickerProviderStateMixin {

  late final AnimationController _controller = AnimationController(
    duration: Duration(milliseconds: 100 * widget.index),
    vsync: this,
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.ease,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // getSizeAndPosition();
      int index = widget.index - widget.selectedIndex;
      if(index < 0) index = index * (-1);
      Future.delayed(Duration(milliseconds: 50 * index), () {
        _controller.forward();
      });
    });
  }

  // getSizeAndPosition() {
  //   RenderBox? item = key.currentContext?.findRenderObject() as RenderBox?;
  //   debugPrint("Size : ${item?.size.width} ${item?.size.height}");
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: InkWell(
        // key: key,
        child: widget.builder(context, widget.value, widget.index, widget.index == widget.selectedIndex),
        onTap: widget.onPressed,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
