import 'package:flutter/material.dart';

class CloseModalIconButton extends StatelessWidget {
  
  final Function()? onTap;

  const CloseModalIconButton({
    Key? key,
    this.onTap
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: GestureDetector(
        /// This padding is to increase the surface area for the gesture detector
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          /// This container is to provide a white background around the cancel icon
          /// so that as we scoll and the content passes underneath the icon we do
          /// not see the content showing up on the transparent parts of the icon
          child: Container(
            decoration: BoxDecoration(
            color: Colors.white,
              borderRadius: BorderRadius.circular(20)
            ),
            child: Icon(Icons.cancel, size: 40, color: Theme.of(context).primaryColor,)
          ),
        ),
        onTap: () => onTap ?? Navigator.of(context).pop(),
      ),
    );

  }
}