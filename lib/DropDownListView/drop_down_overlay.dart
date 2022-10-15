import 'package:flutter/material.dart';

import 'drop_down_list_item.dart';
import 'drop_down_list_view.dart';
import 'package:collection/collection.dart';

class DropDownOverlay extends StatefulWidget {

  final double elevation, gaps;
  final Size btnDimension;
  final Size constraintSize;
  final Offset btnOffset;
  final int selectedIndex;
  final LayerLink? layerLink;
  final ScrollPhysics physics;
  final List<String> items;
  final DropdownItemWidgetBuilder dropdownItemBuilder;
  final VoidCallback onClose;
  final OnValueChanged? onValueChanged;
  final bool safeArea;

  DropDownOverlay({Key? key,
    required this.btnOffset,
    required this.btnDimension,
    required this.constraintSize,
    required this.selectedIndex,
    required this.safeArea,
    this.layerLink,
    this.physics = const NeverScrollableScrollPhysics(),
    required this.items,
    required this.dropdownItemBuilder,
    this.elevation = 0.8,
    this.gaps = 10,
    required this.onClose,
    this.onValueChanged,
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
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _animation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.ease));
    // debugPrint("animation : ${_animation.value}");

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
          _animationController.addListener(() {
            setState(() {
              if(containerHeight == 0){
                containerHeight = (columnKey.currentContext?.findRenderObject() as RenderBox).size.height;
                _animationController.duration = Duration(milliseconds: (containerHeight * 0.8).toInt());
                _animationController.stop();
                _animationController.forward();
              }
            });
          });
          _animationController.forward();
    });

  }


  void onClose() {
    _animationController.reverse().then((value) => widget.onClose());
  }

  void onPressed(item, index){
    _animationController.reverse().then((value) {
      if(widget.onValueChanged != null){
        widget.onValueChanged!(item, index);
      }
    });
  }




  double calculateTop(double animateValue){


    bool topOutbounded = widget.btnOffset.dy - containerHeight < 0;
    bool bottomOutbounded = widget.btnOffset.dy + widget.btnDimension.height + containerHeight > widget.constraintSize.height;
    bool center = !topOutbounded && !bottomOutbounded;

    // debugPrint("TOP:  topOutBounded: $topOutbounded, bottomOutBounded: $bottomOutbounded, full: $center");
    // debugPrint("height: $containerHeight screenSize: ${widget.constraintSize.height}");

    if(topOutbounded && !bottomOutbounded){
      // debugPrint("calculate top with 1");
      return widget.btnOffset.dy + widget.btnDimension.height;
    }

    if(bottomOutbounded && !topOutbounded){
      // debugPrint("calculate top with 2");
      return widget.btnOffset.dy - (containerHeight * animateValue);
    }

    if(topOutbounded && bottomOutbounded){
      // debugPrint("calculate top with 3");
      double top = (widget.btnOffset.dy + (widget.btnDimension.height / 2) - (containerHeight * animateValue)) + (containerHeight * animateValue / 2);
      if ((widget.btnOffset.dy + (widget.btnDimension.height / 2) - containerHeight) + (containerHeight / 2) + containerHeight > widget.constraintSize.height) {
        // top = containerHeight - widget.btnDimension.height - (widget.btnDimension.height / 2) - (widget.btnOffset.dy * animateValue);
        top = widget.btnOffset.dy - (widget.btnOffset.dy * animateValue);
      }
      if (top < 0) top = 0;
      // debugPrint('top $top');
      return top;
    }

    // debugPrint("calculate top with 4");
    return (widget.btnOffset.dy + (widget.btnDimension.height / 2) - (containerHeight * animateValue)) + (containerHeight * animateValue / 2);
  }

  double calculateHeight(double animateValue){

    double height = 0;
    bool topOutbounded = widget.btnOffset.dy - containerHeight < 0;
    bool bottomOutbounded = widget.btnOffset.dy + widget.btnDimension.height + containerHeight > widget.constraintSize.height;
    bool center = !topOutbounded && !bottomOutbounded;

    if(topOutbounded && !bottomOutbounded){
      // debugPrint("calculate height with 1");
      height = containerHeight * animateValue;
      return height;
    }

    if(bottomOutbounded && !topOutbounded){
      // debugPrint("calculate height with 2");
      height = containerHeight * animateValue;
      return height;
    }

    if(topOutbounded && bottomOutbounded){
      // debugPrint("calculate height with 3");
      height = containerHeight;
      if(height > widget.constraintSize.height){
        // debugPrint("over");
        return widget.constraintSize.height * animateValue;
      }
      return height * animateValue;
    }

    // debugPrint("calculate height with 4");
    return containerHeight * animateValue;
  }



  @override
  Widget build(BuildContext context) {


    Widget overlay = Stack(
      children: [
        Container(
            color: Colors.transparent,
            child: SizedBox(
              width: widget.constraintSize.width,
              height: widget.constraintSize.height,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: onClose,
              ),
            )
        ),
        Positioned(
          left: widget.btnOffset.dx,
          top: calculateTop(_animation.value),
          child: FadeTransition(
            opacity: _animation,
            child: Container(
              width: widget.btnDimension.width,
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
                          selectedIndex: widget.selectedIndex,
                          builder: (context, label, index, isSelected) {
                            return widget.dropdownItemBuilder(
                                context,
                                label,
                                index,
                                isSelected
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



    if(widget.safeArea) {
      return SafeArea(child: overlay);
    }

    return overlay;
  }


  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
  //         top: widget.btnOffset.dy + widget.btnDimension.height + widget.btnDimension.height + widget.gaps,
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
  //               width: widget.btnDimension.width,
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
