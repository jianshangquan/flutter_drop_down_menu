import 'package:flutter/material.dart';

import 'drop_down_list_item.dart';
import 'drop_down_list_position.dart';
import 'drop_down_list_view.dart';
import 'package:collection/collection.dart';

class DropDownOverlay extends StatefulWidget {

  final double x, y, floatingTop, floatingLeft, width, height, elevation, gaps, containerHeight;
  final Size size;
  final LayerLink layerLink;
  final DropdownPosition position;
  final ScrollPhysics physics;
  final List<String> items;
  final DropdownItemWidgetBuilder dropdownItemBuilder;
  final VoidCallback onClose;
  final OnValueChanged onValueChanged;

  DropDownOverlay({Key? key,
    required this.x,
    required this.y,
    required this.floatingTop,
    required this.floatingLeft,
    required this.width,
    required this.height,
    required this.containerHeight,
    required this.size,
    required this.layerLink,
    required this.position,
    required this.physics,
    required this.items,
    required this.dropdownItemBuilder,
    required this.elevation,
    required this.gaps,
    required this.onClose,
    required this.onValueChanged,
  }) : super(key: key);

  @override
  State<DropDownOverlay> createState() => _DropDownOverlayState();
}

class _DropDownOverlayState extends State<DropDownOverlay> with SingleTickerProviderStateMixin {

  late final AnimationController _animationController;
  late final Animation<double> _animation;
  final GlobalKey columnKey = GlobalKey();

  double containerHeight = 0;

  @override
  void initState() {
    super.initState();
    debugPrint("init");
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000));
    _animation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.linear));
    debugPrint("animation : ${_animation.value}");

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
          debugPrint("forward");
          _animationController.addListener(() {
            debugPrint("listening, value ${_animation.value}");
            setState(() {
              if(containerHeight == 0){
                containerHeight = (columnKey.currentContext?.findRenderObject() as RenderBox).size.height;
              }
            });
            // debugPrint('size ${(columnKey.currentContext?.findRenderObject() as RenderBox).size}');
            debugPrint('size ${columnKey.currentContext?.size}');
          });
          _animationController.forward();
    });

  }


  void onClose() {
    _animationController.reverse().then((value) => widget.onClose());
  }

  void onPressed(item, index){
    _animationController.reverse().then((value) => widget.onValueChanged(item, index));
  }




  double calculateTop(double animateValue){
    double top = 0;

    if(widget.y - containerHeight < 0){
      return widget.y + widget.height;
    }

    if(widget.y + containerHeight > widget.size.height){
      return widget.y - containerHeight;
    }

    // if(containerHeight > widget.y) {
    //   top = widget.y - (widget.y * animateValue);
    // }
    //
    // top = widget.y - (containerHeight * animateValue / 2);
    //
    // if(top + containerHeight > widget.size.height){
    //   top = widget.y - (containerHeight * animateValue);
    // }
    //
    // if(top < 0){
    //   top = widget.y + widget.height;
    // }

    return top;
  }

  double calculateHeight(double animateValue){
    double height = 0;
    if(containerHeight > widget.y) {
      height = widget.size.height * animateValue;
    }

    height = containerHeight * animateValue;
    return height;
  }



  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
        Container(
            color: Colors.transparent,
            child: SizedBox(
              width: widget.size.width,
              height: widget.size.height,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: onClose,
              ),
            )
        ),
        Positioned(
          left: widget.x,
          top: calculateTop(_animationController.value),
          child: Opacity(
            opacity: _animation.value,
            child: Container(
              width: widget.width,
              height: calculateHeight(_animation.value),
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2 * _animation.value),
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
                  physics: widget.physics,
                  child: Material(
                    color: Colors.transparent,
                    child: Column(
                      key: columnKey,
                      children: widget.items.mapIndexed((index, item) {
                        return DropDownItem(
                          value: item,
                          index: index,
                          builder: (context, label) {
                            return widget.dropdownItemBuilder(
                              context,
                              label,
                            );
                          },
                          onPressed: () => onPressed(item, index),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }


  

  // @override
  // Widget build(BuildContext context) {
  //   return Stack(
  //     children: [
  //       Container(
  //         color: Colors.transparent,
  //         child: SizedBox(
  //           width: widget.size.width,
  //           height: widget.size.height,
  //           child: GestureDetector(
  //             behavior: HitTestBehavior.translucent,
  //             onTap: onClose,
  //           ),
  //         )
  //       ),
  //       Positioned(
  //         left: widget.x,
  //         top: widget.y + widget.height + widget.height + widget.gaps,
  //         child: CompositedTransformFollower(
  //           link: widget.layerLink,
  //           showWhenUnlinked: false,
  //           offset: Offset(
  //               widget.floatingLeft,
  //               (widget.position == DropdownPosition.top ||
  //                   widget.position == DropdownPosition.rightTop ||
  //                   widget.position == DropdownPosition.leftTop)
  //                   ? widget.floatingTop * _animation.value
  //                   : widget.floatingTop),
  //           child: Opacity(
  //             opacity: _animation.value,
  //             child: Container(
  //               width: widget.width,
  //               height: widget.size.height * _animation.value,
  //               clipBehavior: Clip.hardEdge,
  //               decoration: BoxDecoration(
  //                 borderRadius:
  //                 BorderRadius.circular(10 * _animation.value),
  //                 color: Colors.white,
  //                 boxShadow: [
  //                   BoxShadow(
  //                     color:
  //                     Colors.black.withOpacity(0.2 * _animation.value),
  //                     blurRadius: widget.elevation * _animation.value,
  //                     spreadRadius: 0.0,
  //                     offset: const Offset(
  //                         2, 2), // shadow direction: bottom right
  //                   )
  //                 ],
  //               ),
  //               child: ScrollConfiguration(
  //                 behavior: MyBehavior(),
  //                 child: SingleChildScrollView(
  //                   physics:
  //                   widget.physics,
  //                   child: Material(
  //                     color: Colors.transparent,
  //                     child: Column(
  //                       key: columnKey,
  //                       children: widget.items.mapIndexed((index, item) {
  //                         return DropDownItem(
  //                           value: item,
  //                           builder: (context, label) {
  //                             return widget.dropdownItemBuilder(
  //                               context,
  //                               label,
  //                             );
  //                           },
  //                           onPressed: () => onPressed(item, index),
  //                         );
  //                       }).toList(),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }
}
