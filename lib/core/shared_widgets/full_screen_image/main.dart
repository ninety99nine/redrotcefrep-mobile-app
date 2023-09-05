library full_screen_image_null_safe;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// This is an official flutter package that
/// was downloaded and customized by Julian
/// Brandon Tabona
class FullScreenWidget extends StatelessWidget {
  const FullScreenWidget({
    this.backgroundColor = Colors.black,
    this.backgroundIsTransparent = true,
    this.fullScreenChild,
    required this.child,
    this.disposeLevel,
    super.key, 
  });

  final Widget child;
  final Color backgroundColor;
  final Widget? fullScreenChild;
  final bool backgroundIsTransparent;
  final DisposeLevel? disposeLevel;

  @override
  Widget build(BuildContext context) { 
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            opaque: false,
            barrierColor: backgroundIsTransparent
                ? Colors.white.withOpacity(0)
                : backgroundColor,
            pageBuilder: (BuildContext context, _, __) {
              return FullScreenPage(
                backgroundIsTransparent: backgroundIsTransparent,
                backgroundColor: backgroundColor,
                disposeLevel: disposeLevel,
                child: fullScreenChild ?? child,
              );
            }
          )
        );
      },
      child: child,
    );
  }
}

enum DisposeLevel { 
  high, 
  medium, 
  low
}

class FullScreenPage extends StatefulWidget {
  const FullScreenPage({
      super.key, 
      required this.child,
      this.backgroundColor = Colors.black,
      this.backgroundIsTransparent = true,
      this.disposeLevel = DisposeLevel.medium});

  final Widget child;
  final Color backgroundColor;
  final bool backgroundIsTransparent;
  final DisposeLevel? disposeLevel;

  @override
  FullScreenPageState createState() => FullScreenPageState();
}

class FullScreenPageState extends State<FullScreenPage> {

  double textOpacity = 0;

  double? initialPositionY = 0;

  double? currentPositionY = 0;

  double positionYDelta = 0;

  double opacity = 1;

  double disposeLimit = 150;

  late Duration animationDuration;

  @override
  void initState() {
    super.initState();
    setDisposeLevel();
    animationDuration = Duration.zero;

    Future.delayed(const Duration(seconds: 1)).then((value) {
      setState(() {
        textOpacity = 1;
      });
    });
  }

  setDisposeLevel() {
    setState(() {
      if (widget.disposeLevel == DisposeLevel.high) {
        disposeLimit = 300;
      }else if (widget.disposeLevel == DisposeLevel.medium) {
        disposeLimit = 200;
      }else {
        disposeLimit = 100;
      }
    });
  }

  void _startVerticalDrag(details) {
    setState(() {
      initialPositionY = details.globalPosition.dy;
    });
  }

  void _whileVerticalDrag(details) {
    setState(() {
      currentPositionY = details.globalPosition.dy;
      positionYDelta = currentPositionY! - initialPositionY!;
      setOpacity();
    });
  }

  setOpacity() {
    double tmp = positionYDelta < 0
        ? 1 - ((positionYDelta / 1000) * -1)
        : 1 - (positionYDelta / 1000);

    if (tmp > 1) {
      opacity = 1;
    } else if (tmp < 0) {
      opacity = 0;
    }else{
      opacity = tmp;
    }

    if (positionYDelta > disposeLimit || positionYDelta < -disposeLimit) {
      opacity = 0.5;
    }
  }

  void endVerticalDrag(DragEndDetails details) {
    if (positionYDelta > disposeLimit || positionYDelta < -disposeLimit) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        animationDuration = const Duration(milliseconds: 300);
        positionYDelta = 0;
        opacity = 1;
      });

      Future.delayed(animationDuration).then((_){
        setState(() {
          animationDuration = Duration.zero;
        });
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundIsTransparent
          ? Colors.transparent
          : widget.backgroundColor,
      body: GestureDetector(
        onVerticalDragStart: (details) => _startVerticalDrag(details),
        onVerticalDragUpdate: (details) => _whileVerticalDrag(details),
        onVerticalDragEnd: (details) => endVerticalDrag(details),
        child: Container(
          color: widget.backgroundColor.withOpacity(opacity),
          constraints: BoxConstraints.expand(
            height: MediaQuery.of(context).size.height,
          ),
          child: Stack(
            children: <Widget>[
              AnimatedPositioned(
                duration: animationDuration,
                curve: Curves.fastOutSlowIn,
                top: 0 + positionYDelta,
                bottom: 0 - positionYDelta,
                left: 0,
                right: 0,
                child: widget.child,
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AnimatedOpacity(
                        opacity: textOpacity,
                        duration: const Duration(seconds: 1),
                        child: const Text(
                          'Swipe up or down to hide', 
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, size: 40, color: Colors.white,),
                        onPressed: () {
                          Get.back();
                        }, 
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
