import 'package:bonako_demo/features/transactions/widgets/order_transactions/order_transactions_in_horizontal_list_view_infinite_scroll.dart';
import 'package:bonako_demo/features/transactions/widgets/order_transactions/order_transactions_dialog/order_transactions_dialog.dart';
import 'package:bonako_demo/core/shared_widgets/loader/custom_circular_progress_indicator.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_title_large_text.dart';
import 'package:bonako_demo/features/transactions/enums/transaction_enums.dart';
import 'package:bonako_demo/core/shared_widgets/button/custom_text_button.dart';
import 'order_payment/order_request_payment/order_request_payment_button.dart';
import 'package:bonako_demo/core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/transactions/models/transaction.dart';
import 'package:bonako_demo/features/orders/providers/order_provider.dart';
import 'package:bonako_demo/features/stores/models/shoppable_store.dart';
import 'order_payment/order_mark_as_paid/order_mark_as_paid_button.dart';
import 'package:bonako_demo/core/shared_widgets/cards/custom_card.dart';
import 'package:bonako_demo/features/orders/models/order.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class OrderPaymentDetails extends StatefulWidget {
  
  final Order order;
  final Function()? onMarkedAsPaid;
  final Function(Transaction)? onRequestPayment;
  final Function(int)? onRequestedTransactionsCount;

  const OrderPaymentDetails({
    Key? key,
    this.onMarkedAsPaid,
    required this.order,
    this.onRequestPayment,
    this.onRequestedTransactionsCount
  }) : super(key: key);

  @override
  State<OrderPaymentDetails> createState() => _OrderPaymentDetailsState();
}

class _OrderPaymentDetailsState extends State<OrderPaymentDetails> {
  
  late Order order;
  bool isLoading = false;
  Function()? get onMarkedAsPaid => widget.onMarkedAsPaid;
  void _startLoader() => setState(() => isLoading = true);
  void _stopLoader() => setState(() => isLoading = false);
  bool get canMarkAsPaid => order.attributes.canMarkAsPaid;
  ShoppableStore get store => widget.order.relationships.store!;
  bool get canRequestPayment => order.attributes.canRequestPayment;
  bool get hasOrderTransactions => (order.transactionsCount ?? 0) > 0;
  bool get doesntHaveOrderTransactions => order.transactionsCount == 0;
  Function(Transaction)? get onRequestPayment => widget.onRequestPayment;
  bool get canManageOrders => store.attributes.userStoreAssociation!.canManageOrders;
  OrderProvider get orderProvider => Provider.of<OrderProvider>(context, listen: false);
  Function(int)? get onRequestedTransactionsCount => widget.onRequestedTransactionsCount;

  @override
  void initState() {
    super.initState();

    order = widget.order;
    
    /// If the transaction count does not exist, then request this order transactions conut
    if(order.transactionsCount == null) _requestOrderTransactionsCount();
  }

  void _requestOrderTransactionsCount() async {

    _startLoader();

    orderProvider.setOrder(order).orderRepository.showOrderTransactionsCount().then((response) {

      final responseBody = jsonDecode(response.body);

      if(response.statusCode == 200) {

        /// Set the total transactions on this order
        setState(() => order.transactionsCount = responseBody['total']);

        if(onRequestedTransactionsCount != null) onRequestedTransactionsCount!(order.transactionsCount!);

      }

    }).whenComplete(() {
      _stopLoader();
    });

  }

  List<Widget> get content {


    return [

      /// Payment Progress
      isLoading ? const CustomCircularProgressIndicator() : Column(
        children: hasOrderTransactions ? [

          /// Payment Progress
          paymentProgress,

          /// Spacer
          const SizedBox(height: 16.0,),

          /// Order Transaction Avatars
          OrderTransactionsInHorizontalListViewInfiniteScroll(
            order: order,
            store: store,
          ),
            
          /// Spacer
          const SizedBox(height: 16.0,),

        ] : [],
      ),

      if(canRequestPayment || canMarkAsPaid) ...[

        Row(
          mainAxisAlignment: canRequestPayment ? MainAxisAlignment.spaceBetween : MainAxisAlignment.end,
          children: [

            /// Order Request Payment Button
            if(canRequestPayment) OrderRequestPaymentButton(order: order, onRequestPayment: onRequestPayment),

            /// Order Mark As Paid Button
            if(canMarkAsPaid) OrderMarkAsPaidButton(order: order, onMarkedAsPaid: onMarkedAsPaid),

          ],
        ),

        /// Divider
        const Divider(),

      ],

    ];

  }

  Widget get paymentProgress {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
    
              /// Title
              const CustomTitleLargeText('Payments'),
    
              /// Total Payment Requests
              if(order.transactionsCount != 0) totalRequests
    
            ],
          ),

          /// Spacer
          const SizedBox(height: 8),

          /// Order Amount Paid
          amountPaid,

          /// Spacer
          const SizedBox(height: 8),

          /// Progress Bar
          progressBar

        ],
      )
    );
  }

  Widget get totalRequests {

    final String totalRequestsAsText = '${order.transactionsCount} ${order.transactionsCount == 1 ? 'Request' : 'Requests'}';

    return OrderTransactionsDialog(
      order: order,
      transactionContentView: TransactionContentView.viewingTransactions,
      trigger: (openBottomModalSheet) => CustomTextButton(
        totalRequestsAsText, 
        onPressed: openBottomModalSheet
      ),
    );

  }

  Widget get amountPaid {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        /// Title
        const CustomBodyText('Amount paid'),

        /// Order Amount Paid
        CustomBodyText('${order.amountPaid.amountWithCurrency} (${order.amountPaidPercentage.valueSymbol})'),

      ],
    );
  }

  Widget get progressBar {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(8.0)),
      child: LinearProgressIndicator(
        minHeight: 8,
        color: Colors.green,
        backgroundColor: Colors.grey.shade200,
        value: (50 / 100),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: content,
    );
  }
}