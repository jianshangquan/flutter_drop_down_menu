import 'package:flutter/material.dart';

import 'drop_down_list_view.dart';


class DropDownItem extends StatelessWidget {
  String value;
  VoidCallback? onPressed;
  DropdownItemWidgetBuilder builder;

  DropDownItem({Key? key, required this.value, required this.onPressed, required this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: builder(context, value),
      onTap: onPressed,
    );
  }
}
