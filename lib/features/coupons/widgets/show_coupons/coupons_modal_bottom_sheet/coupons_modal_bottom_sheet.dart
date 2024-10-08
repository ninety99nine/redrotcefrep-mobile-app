import '../../../../../core/shared_widgets/bottom_modal_sheet/custom_bottom_modal_sheet.dart';
import 'package:perfect_order/features/stores/providers/store_provider.dart';
import '../../../../../core/shared_widgets/text/custom_body_text.dart';
import 'package:perfect_order/features/coupons/enums/coupon_enums.dart';
import 'package:perfect_order/features/coupons/models/coupon.dart';
import '../../../../stores/models/shoppable_store.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../coupons_content.dart';

enum TriggerType {
  addCoupon,
  editCoupon,
  totalCoupons
}

class CouponsModalBottomSheet extends StatefulWidget {
  
  final Coupon? coupon;
  final ShoppableStore store;
  final TriggerType triggerType;
  final Widget Function(void Function())? trigger;

  const CouponsModalBottomSheet({
    super.key,
    this.trigger,
    this.coupon,
    required this.store,
    this.triggerType = TriggerType.totalCoupons
  });

  @override
  State<CouponsModalBottomSheet> createState() => _CouponsModalBottomSheetState();
}

class _CouponsModalBottomSheetState extends State<CouponsModalBottomSheet> {

  CouponContentView? couponContentView;
  Coupon? get coupon => widget.coupon;
  ShoppableStore get store => widget.store;
  TriggerType get triggerType => widget.triggerType;
  Widget Function(void Function())? get trigger => widget.trigger;
  String get totalCoupons => widget.store.couponsCount!.toString();
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  String get totalCouponsText => widget.store.couponsCount == 1 ? 'Coupon' : 'Coupons';

  /// This allows us to access the state of CustomBottomModalSheet widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<CustomBottomModalSheetState> _customBottomModalSheetState = GlobalKey<CustomBottomModalSheetState>();

  @override
  void initState() {
    super.initState();

    /// If the trigger is null and the trigger type is add coupon
    if( trigger == null && triggerType == TriggerType.addCoupon ) {

      /// Set the coupon content view to creating coupon
      couponContentView = CouponContentView.creatingCoupon;

    }
  }

  Widget get _trigger {

    final Widget addCouponTrigger = Container(
      margin: const EdgeInsets.only(top: 5),
      child: DottedBorder(
        color: Colors.grey,
        radius: const Radius.circular(8),
        borderType: BorderType.RRect,
        strokeCap: StrokeCap.butt,
        padding: EdgeInsets.zero,
        dashPattern: const [6, 3], 
        strokeWidth: 1,
        child: Material(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          color:Colors.grey.shade100,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => openBottomModalSheet(),
            child: Ink(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.add, size: 16, color: Colors.grey.shade400,),
                      const SizedBox(width: 4,),
                      const CustomBodyText('Add Coupon', lightShade: true,)
                    ],
                  )
                ),
              ),
            ),
          ),
        ),
      ),
    );

    const Widget editCouponTrigger = Icon(Icons.mode_edit_outline_outlined);

    /// If the trigger is null and the trigger type is total coupons
    if( trigger == null && triggerType == TriggerType.totalCoupons ) {

      /// Return the total coupons and total coupons text
      return CustomBodyText([totalCoupons, totalCouponsText]);
    
    /// If the trigger is null and the trigger type is add coupon
    }else if( trigger == null && triggerType == TriggerType.addCoupon ) {

      /// Return the add coupon trigger
      return addCouponTrigger;

    /// If the trigger is null and the trigger type is edit coupon
    }else if( trigger == null && triggerType == TriggerType.editCoupon ) {

      /// Return the edit coupon trigger
      return editCouponTrigger;

    }else{

      /// If the trigger is not null, return the custom trigger
      return trigger!(openBottomModalSheet);

    }

  }

  /// Open the bottom modal sheet
  void openBottomModalSheet() {
    if(_customBottomModalSheetState.currentState != null) {
      _customBottomModalSheetState.currentState!.showBottomSheet(context);
    } 
  }

  @override
  Widget build(BuildContext context) {
    return CustomBottomModalSheet(
      key: _customBottomModalSheetState,
      /// Trigger to open the bottom modal sheet
      trigger: _trigger,
      /// Content of the bottom modal sheet
      content: CouponsContent(
        store: store,
        coupon: coupon,
        couponContentView: couponContentView,
      ),
    );
  }
}