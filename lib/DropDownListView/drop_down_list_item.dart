import 'dart:math';

import 'package:flutter/material.dart';

import 'drop_down_list_view.dart';


class DropDownItem extends StatefulWidget {
  String value;
  VoidCallback? onPressed;
  DropdownItemWidgetBuilder builder;

  DropDownItem({Key? key, required this.value, required this.onPressed, required this.builder}) : super(key: key);

  @override
  State<DropDownItem> createState() => _DropDownItemState();
}

class _DropDownItemState extends State<DropDownItem> {

  final GlobalKey key = GlobalKey();
  final double height = Random().nextDouble() * 100;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => getSizeAndPosition());
  }

  getSizeAndPosition() {
    RenderBox? item = key.currentContext?.findRenderObject() as RenderBox?;
    debugPrint("Size : ${item?.size.width} ${item?.size.height}");
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
}
