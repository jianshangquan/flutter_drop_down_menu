import 'package:flutter/material.dart';

import 'drop_down_list_item.dart';
import 'drop_down_list_view.dart';
import 'package:collection/collection.dart';


typedef GetOffset = Map<String, dynamic> Function();
typedef GetConstraint = Size Function();

class DropDownOverlay extends StatefulWidget {

  final double elevation, transitionPerPixel;
  final int selectedIndex;
  final ScrollPhysics physics;
  final List<String> items;
  final DropdownItemWidgetBuilder dropdownItemBuilder;
  final VoidCallback onClose;
  final OnValueChanged? onValueChanged;
  final bool safeArea;
  final Curve curve;
  final GetOffset getBtnOffsetDimension;
  final GetConstraint getConstraint;

  DropDownOverlay({Key? key,
    required this.selectedIndex,
    required this.safeArea,
    required this.getBtnOffsetDimension,
    required this.getConstraint,
    this.transitionPerPixel = 0.5,
    this.curve = Curves.ease,
    this.physics = const NeverScrollableScrollPhysics(),
    required this.items,
    required this.dropdownItemBuilder,
    this.elevation = 0.8,
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

  late Map<String, dynamic> btnOffsetDimension = widget.getBtnOffsetDimension();
  late Size constraintSize = widget.getConstraint();

  double containerHeight = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _animation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animationController, curve: widget.curve));
    // debugPrint("animation : ${_animation.value}");

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
          _animationController.addListener(() {
            setState(() {
              if(containerHeight == 0){
                containerHeight = (columnKey.currentContext?.findRenderObject() as RenderBox).size.height;
                _animationController.duration = Duration(milliseconds: (containerHeight * widget.transitionPerPixel).toInt());
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
    Size size = btnOffsetDimension['size'];
    Offset offset = btnOffsetDimension['offset'];

    bool topOutbounded = offset.dy - containerHeight < 0;
    bool bottomOutbounded = offset.dy + size.height + containerHeight > constraintSize.height;
    bool center = !topOutbounded && !bottomOutbounded;

    // debugPrint("TOP:  topOutBounded: $topOutbounded, bottomOutBounded: $bottomOutbounded, full: $center");
    // debugPrint("height: $containerHeight screenSize: ${widget.constraintSize.height}");

    if(topOutbounded && !bottomOutbounded){
      // debugPrint("calculate top with 1");
      return offset.dy + size.height;
    }

    if(bottomOutbounded && !topOutbounded){
      // debugPrint("calculate top with 2");
      return offset.dy - (containerHeight * animateValue);
    }

    if(topOutbounded && bottomOutbounded){
      // debugPrint("calculate top with 3");
      double top = (offset.dy + (size.height / 2) - (containerHeight * animateValue)) + (containerHeight * animateValue / 2);
      if ((offset.dy + (size.height / 2) - containerHeight) + (containerHeight / 2) + containerHeight > constraintSize.height) {
        // top = containerHeight - btnSize.height - (btnSize.height / 2) - (btnOffset.dy * animateValue);
        top = offset.dy - (offset.dy * animateValue);
      }
      if (top < 0) top = 0;
      // debugPrint('top $top');
      return top;
    }

    // debugPrint("calculate top with 4");
    return (offset.dy + (size.height / 2) - (containerHeight * animateValue)) + (containerHeight * animateValue / 2);
  }

  double calculateHeight(double animateValue){

    Size size = btnOffsetDimension['size'];
    Offset offset = btnOffsetDimension['offset'];

    double height = 0;
    bool topOutbounded = offset.dy - containerHeight < 0;
    bool bottomOutbounded = offset.dy + size.height + containerHeight > constraintSize.height;
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
      if(height > constraintSize.height){
        // debugPrint("over");
        return constraintSize.height * animateValue;
      }
      return height * animateValue;
    }

    // debugPrint("calculate height with 4");
    return containerHeight * animateValue;
  }



  @override
  Widget build(BuildContext context) {

    Widget overlay = LayoutBuilder(
      builder: (context, constraint) {
        btnOffsetDimension = widget.getBtnOffsetDimension();
        Size size = btnOffsetDimension['size'];
        Offset offset = btnOffsetDimension['offset'];


        return Stack(
          children: [
            Container(
                color: Colors.transparent,
                child: SizedBox(
                  width: constraintSize.width,
                  height: constraintSize.height,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: onClose,
                  ),
                )
            ),
            Positioned(
              left: offset.dx,
              top: calculateTop(_animation.value),
              child: FadeTransition(
                opacity: _animation,
                child: Container(
                  width: size.width,
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
      },
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
  //         top: btnOffset.dy + btnSize.height + btnSize.height + widget.gaps,
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
  //               width: btnSize.width,
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
