import 'dart:math';

import 'package:flutter/material.dart';

import 'drop_down_list_view.dart';


typedef OnChildRendered = void Function(Size size);

class DropDownItem extends StatefulWidget {
  String value;
  VoidCallback? onPressed;
  DropdownItemWidgetBuilder builder;
  OnChildRendered onChildRendered;
  int index;

  DropDownItem({Key? key, required this.value, required this.onPressed, required this.builder, required this.index,
  required this.onChildRendered}) : super(key: key);

  @override
  State<DropDownItem> createState() => _DropDownItemState();
}

class _DropDownItemState extends State<DropDownItem> with TickerProviderStateMixin {

  final GlobalKey key = GlobalKey();
  final double height = Random().nextDouble() * 20;
  // late final AnimationController _controller = AnimationController(
  //   duration: const Duration(milliseconds: 150),
  //   vsync: this,
  // );
  // late final Animation<double> _animation = CurvedAnimation(
  //   parent: _controller,
  //   curve: Curves.easeIn,
  // );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getSizeAndPosition();
      // Future.delayed(Duration(milliseconds: 100 * widget.index), () {
      //   _controller.forward();
      // });
    });
  }



  getSizeAndPosition() {
    RenderBox? item = key.currentContext?.findRenderObject() as RenderBox?;
    debugPrint("Size : ${item?.size.width} ${item?.size.height}");
    widget.onChildRendered(item!.size);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: key,
      child: Container(
          padding: EdgeInsets.only(top: height),
          child: widget.builder(context, widget.value)
      ),
      onTap: widget.onPressed,
    );
  }

  @override
  void dispose() {
    // _controller.dispose();
    super.dispose();
  }
}
