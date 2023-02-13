import '../text/custom_body_text.dart';
import 'package:flutter/material.dart';
import 'custom_choice_chip.dart';

class CustomFilterChoiceChip extends StatelessWidget {
  
  final String name;
  final bool showTotal;
  final bool isSelected;
  final String totalSummarized;
  final Function(String) onSelected;

  const CustomFilterChoiceChip({
    super.key,
    required this.name,
    required this.showTotal,
    required this.isSelected,
    required this.onSelected,
    required this.totalSummarized,
  });

  double get width {

    double width;

    /// Total characters length e.g 2 = 1, 20 = 2, 200 = 3, e.t.c
    final int totalCharactersLength = totalSummarized.length;

    /**
      * If total = 1 then width is 28,
      * If total = 1k then width is 36,
      * If total = 10k then width is 46,
      * If total = 100k then width is 54,
      * If total = 1m then width is 36,
      * ... e.t.c
      */
    List<double> widthsByCharacterLength = [
      28, 36, 46, 54
    ];

    /// Dynamically hide or show the total
    if(showTotal) {

      /// Set the dynamic width based on the total characters
      width = widthsByCharacterLength[totalCharactersLength - 1];

    }else{

      /// Set the width to zero to hide the total
      width = 0;
    
    }

    return width;

  }

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: CustomChoiceChip(
        labelWidget: Row(
          children: [
            
            /// Name
            CustomBodyText(name, color: isSelected ? Colors.white : Colors.black),
            
            AnimatedContainer(
              width: width,
              clipBehavior: Clip.antiAlias,
              margin: const EdgeInsets.only(left: 4),
              duration: const Duration(milliseconds: 500),
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected ? null : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12)
              ),

              /// Total Summarized
              child: CustomBodyText(
                totalSummarized, 
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black,
              )
            ),

          ],
        ),
        selected: isSelected,
        onSelected: (value) {
          onSelected(name);
        },
      ),
    );
  }
}