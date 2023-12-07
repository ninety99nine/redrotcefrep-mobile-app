import 'package:bonako_demo/core/shared_widgets/text/custom_title_small_text.dart';
import 'package:bonako_demo/features/occasions/providers/occasion_provider.dart';
import 'package:bonako_demo/core/shared_widgets/chips/custom_choice_chip.dart';
import 'package:bonako_demo/features/occasions/models/occasion.dart';
import '../../../stores/models/shoppable_store.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class OccasionDetails extends StatefulWidget {
  const OccasionDetails({super.key});

  @override
  State<OccasionDetails> createState() => _OccasionDetailsState();
}

class _OccasionDetailsState extends State<OccasionDetails> {
  
  ShoppableStore? store;
  bool isLoading = false;
  List<Occasion> occasions = [];
  void _startLoader() => setState(() => isLoading = true);
  void _stopLoader() => setState(() => isLoading = false);

  bool get hasOccasions => occasions.isNotEmpty;
  bool get hasSelectedOccasion => store!.occasion != null;
  bool get hasSelectedProducts => store == null ? false : store!.hasSelectedProducts;
  OccasionProvider get occasionProvider => Provider.of<OccasionProvider>(context, listen: false);

  void _requestOccasions() async {

    if(isLoading) return;

    _startLoader();

    occasionProvider.occasionRepository.showOccasions().then((response) {

      if(response.statusCode == 200) {
        setState(() {
          occasions = (response.data['data'] as List).map((occasion) {
            return Occasion.fromJson(occasion);
          }).toList();
        });
      }

    }).whenComplete(() {

      _stopLoader();
    
    });

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    /// Get the updated Shoppable Store Model
    store = Provider.of<ShoppableStore>(context, listen: false);

    /// If we have selected products and we don't have occasions and we are not loading
    if(hasSelectedProducts && !hasOccasions && !isLoading) {
      _requestOccasions();
    }
  }

  @override
  Widget build(BuildContext context) {

    /// Capture the store that was passed on ListenableProvider.value() of the StoreCard. 
    /// This store is accessible if the StoreCard is an ancestor of this 
    /// ShoppableProductCards. We can use this shoppable store instance 
    /// for shopping purposes e.g selecting this product so that we 
    /// can place an order.
    store = Provider.of<ShoppableStore>(context, listen: true);
    
    return SizedBox(
      width: double.infinity,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 500),
        child: AnimatedSwitcher(
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          duration: const Duration(milliseconds: 500),
          child: Column(
            children: hasSelectedProducts && hasOccasions ? [
              
              //  Divider
              const Divider(),
    
              /// Spacer
              const SizedBox(height: 8),
              
              /// Title
              const CustomTitleSmallText('What\'s the occasion?'),
    
              /// Spacer
              const SizedBox(height: 8),
    
              /// Occasions (🥳 Happy Birthday | 🏥 Get Well Soon | 🌼 Mothers Day)
              ClipRRect(
                clipBehavior: Clip.antiAlias,
                borderRadius: BorderRadius.circular(24),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
    
                        // First Row of Chips
                        Row(
                          children: [
                            CustomChoiceChip(
                              label: 'None',
                              selected: !hasSelectedOccasion,
                              selectedColor: Colors.green.shade700,
                              onSelected: (bool isSelected) {
                                if (isSelected) {
                                  store!.updateOccasion(null);
                                }
                              },
                            ),
    
                            /// Spacing
                            const SizedBox(width: 4),
    
                            for (int i = 0; i < occasions.length; i++) ...[
    
                              /// Spacing
                              const SizedBox(width: 4),
    
                              /// Display every other occasion in the first row
                              if (i % 2 == 0)
                                CustomChoiceChip(
                                  selected: store!.occasion?.name == occasions[i].name,
                                  label: occasions[i].name,
                                  selectedColor: Colors.green.shade700,
                                  onSelected: (bool isSelected) =>
                                      store!.updateOccasion(occasions[i]),
                                ),
                            ],
                          ],
                        ),
                        
                        // Second Row of Chips
                        Row(
                          children: [
                            for (int i = 0; i < occasions.length; i++) ...[
    
                              /// Spacing
                              if(i != 0) const SizedBox(width: 4),
    
                              /// Display the remaining occasions in the second row
                              if (i % 2 != 0)
                                CustomChoiceChip(
                                  selected: store!.occasion?.name == occasions[i].name,
                                  label: occasions[i].name,
                                  selectedColor: Colors.green.shade700,
                                  onSelected: (bool isSelected) =>
                                      store!.updateOccasion(occasions[i]),
                                ),
                            ],
                          ],
                        ),
                      ],
                    )
                ),
              ),
    
              /// Spacer
              const SizedBox(height: 8),
    
            ] : [],
          )
        ),
      ),
    );
  }
}