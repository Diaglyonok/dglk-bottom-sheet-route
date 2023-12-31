library dglk_bottom_sheet_route;

import 'package:flutter/material.dart';

class BottomSheetRoute<T> extends ModalRoute<T> {
  BottomSheetRoute({
    required this.builder,
    this.bottomSheetController,
    this.color,
    this.showGrip,
    this.gripColor,
    this.titleBoxHeight,
  });
  bool isPopped = false;

  final Widget Function(BuildContext context) builder;
  final BottomSheetController? bottomSheetController;
  final Color? color;
  final Color? gripColor;
  final bool? showGrip;
  final double? titleBoxHeight;

  @override
  Future<RoutePopDisposition> willPop() {
    if (isPopped) {
      return Future.value(RoutePopDisposition.doNotPop);
    }
    isPopped = true;
    return super.willPop();
  }

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Color get barrierColor => Colors.black.withOpacity(0.4);

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  bool get opaque => false;

  @override
  bool get semanticsDismissible => true;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    if (bottomSheetController != null) {
      bottomSheetController!.registerListener(() {
        if (!isPopped) {
          isPopped = true;
          Navigator.of(context).pop();
        }
      });
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Dismissible(
          key: const Key("dismissible"),
          direction: DismissDirection.down,
          onDismissed: (direction) {
            if (!isPopped) {
              isPopped = true;
              Navigator.of(context).pop();
            }
          },
          child: AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: Column(
              children: <Widget>[
                ClipRRect(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                  child: Container(
                    color: color ?? Theme.of(context).colorScheme.background,
                    constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.9,
                        minWidth: MediaQuery.of(context).size.width),
                    child: _childWrapper(context),
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget buildTransitions(
      BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 1), end: const Offset(0, 0)).animate(animation),
      child: child,
    );
  }

  Widget _childWrapper(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      GestureDetector(
          child: Container(
            height: titleBoxHeight ?? 20,
            color: Colors.transparent,
            child: Align(
              alignment: Alignment.center,
              child: Visibility(
                visible: showGrip ?? true,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: Container(
                    width: 40,
                    height: 4,
                    color: gripColor ?? Theme.of(context).colorScheme.onBackground.withOpacity(0.4),
                  ),
                ),
              ),
            ),
          ),
          onTap: () {
            if (!isPopped) {
              isPopped = true;
              Navigator.of(context).pop();
            }
          }),
      Flexible(
        child: Material(
          type: MaterialType.transparency,
          child: builder(context),
        ),
      ),
    ]);
  }
}

class BottomSheetController {
  Function? popCallback;

  void registerListener(Function popCallback) {
    this.popCallback = popCallback;
  }

  void pop() {
    if (popCallback != null) {
      popCallback!();
    }
  }

  dispose() {
    popCallback = null;
  }
}
