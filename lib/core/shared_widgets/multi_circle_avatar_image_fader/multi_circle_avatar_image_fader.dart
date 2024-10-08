import 'package:perfect_order/core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import '../../constants/constants.dart' as constants;
import 'package:flutter/material.dart';

class CustomMultiCircleAvatarImageFader extends StatefulWidget {

  final double size;
  final bool isLoading;
  final List<String> imagePaths;
  final Function(Color)? onSelectedRainbowColor;

  const CustomMultiCircleAvatarImageFader({
    super.key,
    this.size = 100,
    this.isLoading = false,
    this.imagePaths = const [],
    this.onSelectedRainbowColor,
  });

  @override
  CustomMultiCircleAvatarImageFaderState createState() => CustomMultiCircleAvatarImageFaderState();
}

class CustomMultiCircleAvatarImageFaderState extends State<CustomMultiCircleAvatarImageFader> with TickerProviderStateMixin {
  
  int _currentIndex = 0;
  late Color? rainbowColor;
  late AnimationController _controller;
  List<Color> rainbowColors = constants.rainbowColors;

  double get size => widget.size;
  bool get isLoading => widget.isLoading;
  List<String> get imagePaths => widget.imagePaths;
  Function(Color)? get onSelectedRainbowColor => widget.onSelectedRainbowColor;

  @override
  void initState() {
    super.initState();

    rainbowColor = rainbowColors.first;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), // Set the duration of each image display
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
        setState(() {
          _currentIndex = (_currentIndex + 1) % imagePaths.length;
          rainbowColor = rainbowColors[_currentIndex];
          notifyParentOnSelectedRainbowColor();
        });
        _controller.forward();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void notifyParentOnSelectedRainbowColor() {
    if(onSelectedRainbowColor != null) {
      onSelectedRainbowColor!(rainbowColor!);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(4), /// Adjust the padding as needed for the width of the border
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          colors: rainbowColors,  /// Apply the rainbow colors
        ),
      ),
      child: AnimatedSwitcher(
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        duration: const Duration(seconds: 2),
        child: CircleAvatar(
          radius: size / 2,
          backgroundImage: AssetImage(imagePaths[_currentIndex]),
          key: ValueKey<String>(imagePaths[_currentIndex]),
          child: isLoading ? Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              shape: BoxShape.circle
            ),
            child: CustomCircularProgressIndicator(
              color: rainbowColor,
            )
          ) : null,
        ),
      )
    );
  }
}