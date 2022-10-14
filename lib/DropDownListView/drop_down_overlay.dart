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
        vsync: this, duration: Duration(milliseconds: 200));
    _animation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.ease));
    // debugPrint("animation : ${_animation.value}");

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
          // debugPrint("forward");
          _animationController.addListener(() {
            // debugPrint("listening, value ${_animation.value}");
            setState(() {
              if(containerHeight == 0){
                containerHeight = (columnKey.currentContext?.findRenderObject() as RenderBox).size.height;
                _animationController.duration = Duration(milliseconds: (containerHeight * 0.5).toInt());
                _animationController.stop();
                _animationController.forward();
              }
            });
            // debugPrint('size ${(columnKey.currentContext?.findRenderObject() as RenderBox).size}');
            // debugPrint('size ${columnKey.currentContext?.size}');
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


    bool topOutbounded = widget.y - containerHeight < 0;
    bool bottomOutbounded = widget.y + widget.height + containerHeight > widget.size.height;
    bool center = !topOutbounded && !bottomOutbounded;

    debugPrint("TOP:  topOutBounded: $topOutbounded, bottomOutBounded: $bottomOutbounded, full: $center");
    debugPrint("height: $containerHeight screenSize: ${widget.size.height}");

    if(topOutbounded && !bottomOutbounded){
      debugPrint("calculate top with 1");
      return widget.y + widget.height;
    }

    if(bottomOutbounded && !topOutbounded){
      debugPrint("calculate top with 2");
      return widget.y - (containerHeight * animateValue);
    }

    if(topOutbounded && bottomOutbounded){
      debugPrint("calculate top with 3");
      double top = (widget.y + (widget.height / 2) - (containerHeight * animateValue)) + (containerHeight * animateValue / 2);
      if ((widget.y + (widget.height / 2) - containerHeight) + (containerHeight / 2) + containerHeight > widget.size.height) {
        // top = containerHeight - widget.height - (widget.height / 2) - (widget.y * animateValue);
        top = widget.y - (widget.y * animateValue);
      }
      if (top < 0) top = 0;
      debugPrint('top $top');
      return top;
    }

    debugPrint("calculate top with 4");
    return (widget.y + (widget.height / 2) - (containerHeight * animateValue)) + (containerHeight * animateValue / 2);
  }

  double calculateHeight(double animateValue){

    double height = 0;
    bool topOutbounded = widget.y - containerHeight < 0;
    bool bottomOutbounded = widget.y + widget.height + containerHeight > widget.size.height;
    bool center = !topOutbounded && !bottomOutbounded;

    if(topOutbounded && !bottomOutbounded){
      debugPrint("calculate height with 1");
      height = containerHeight * animateValue;
      return height;
    }

    if(bottomOutbounded && !topOutbounded){
      debugPrint("calculate height with 2");
      height = containerHeight * animateValue;
      return height;
    }

    if(topOutbounded && bottomOutbounded){
      debugPrint("calculate height with 3");
      height = containerHeight;
      if(height > widget.size.height){
        debugPrint("over");
        return widget.size.height * animateValue;
      }
      return height * animateValue;
    }

    debugPrint("calculate height with 4");
    return containerHeight * animateValue;
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
          top: calculateTop(_animation.value),
          child: FadeTransition(
            opacity: _animation,
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
                      mainAxisSize: MainAxisSize.min,
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
