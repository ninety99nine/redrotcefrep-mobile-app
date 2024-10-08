import 'package:perfect_order/features/transactions/widgets/order_transactions/order_transactions_in_vertical_list_view_infinite_scroll.dart';
import 'package:perfect_order/features/transactions/widgets/order_transactions/order_transaction_filters.dart';
import '../../../../core/shared_widgets/button/custom_elevated_button.dart';
import '../../../../core/shared_widgets/text/custom_title_medium_text.dart';
import 'package:perfect_order/features/transactions/models/transaction.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import 'package:perfect_order/features/orders/models/order.dart';
import 'order_transactions_page/order_transactions_page.dart';
import 'package:perfect_order/core/shared_models/user.dart';
import '../../enums/transaction_enums.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderTransactionsContent extends StatefulWidget {
  
  final Order order;
  final User? paidByUser;
  final bool showingFullPage;
  final Transaction? transaction;
  final String? transactionFilter;
  final Function(Transaction, String)? onSubmittedFile;
  final TransactionContentView? transactionContentView;

  const OrderTransactionsContent({
    super.key,
    this.paidByUser,
    this.transaction,
    required this.order,
    this.onSubmittedFile,
    this.transactionFilter,
    this.transactionContentView,
    this.showingFullPage = false
  });

  @override
  State<OrderTransactionsContent> createState() => _OrderTransactionsContentState();
}

class _OrderTransactionsContentState extends State<OrderTransactionsContent> {

  bool isDeleting = false;
  Transaction? transaction;
  bool isSubmitting = false;
  String transactionFilter = 'All';
  bool disableFloatingActionButton = false;
  TransactionContentView transactionContentView = TransactionContentView.viewingTransactions;

  /// This allows us to access the state of UpdateStoreForm widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<OrderTransactionFiltersState> orderPayingUserTransactionFiltersState = GlobalKey<OrderTransactionFiltersState>();

  Order get order => widget.order;
  User? get paidByUser => widget.paidByUser;
  double get topPadding => showingFullPage ? 32 : 0;
  bool get showingFullPage => widget.showingFullPage;
  Function(Transaction, String)? get onSubmittedFile => widget.onSubmittedFile;
  bool get isViewingRequestPayment => transactionContentView == TransactionContentView.requestPayment;
  bool get isViewingTransaction => transactionContentView == TransactionContentView.viewingTransaction;
  bool get isViewingTransactions => transactionContentView == TransactionContentView.viewingTransactions;

  String get title {

    if(isViewingTransactions) {

      return 'Transactions';
    
    }else if(isViewingTransaction) {
      
      return 'Transaction #${transaction!.id}';
    
    }else if(isViewingRequestPayment) {
      
      return 'Add Payment';
    
    }else{

      return '';

    }

  }
  
  String get subtitle {

    if(isViewingTransactions) {
      
      if(paidByUser == null) {
        
        return 'Order #${order.attributes.number}';

      }else{
        
        return 'By ${paidByUser!.attributes.name}';

      }
    
    }else if(isViewingTransaction) {
      
      if(paidByUser == null) {
        
        return 'Order #${order.attributes.number}';

      }else{
        
        return 'By ${paidByUser!.attributes.name}';

      }
    
    }else if(isViewingRequestPayment) {
      
      if(paidByUser == null) {
        
        return 'Request for payment';

      }else{
        
        return 'Request ${paidByUser!.firstName} to pay';

      }
    
    }else{

      return '';

    }
    
  }

  @override
  void initState() {
    super.initState();
    transaction = widget.transaction;
    if(widget.transactionContentView != null) {
      transactionContentView = widget.transactionContentView!;
    }
  }

  /// Content to show based on the specified view
  Widget get content {
      
    return OrderTransactionsInVerticalListViewInfiniteScroll(
      order: order,
      paidByUser: paidByUser,
      onSubmittedFile: onSubmittedFile,
      transactionFilter: transactionFilter,
      onSelectedTransaction: onSelectedTransaction,
      orderPayingUserTransactionFiltersState: orderPayingUserTransactionFiltersState
    );
    
  }

  void onSelectedTransaction(Transaction transaction) {
    this.transaction = transaction;
    changeTransactionContentView(TransactionContentView.viewingTransaction);
  }

  /// Floating action button widget
  Widget get floatingActionButton {

    return Row(
      children: [

        if( isViewingTransaction ) ...[

          /// Back button
          SizedBox(
            width: 48,
            child: CustomElevatedButton(
              '',
              color: Colors.grey,
              onPressed: floatingActionButtonOnPressed,
              prefixIcon: Icons.keyboard_double_arrow_left,
            ),
          ),

        ],

        if( isViewingTransactions ) ...[

          const SizedBox(width: 8),

          /// Request Payment button
          CustomElevatedButton(
            'Add Payment',
            width: 120,
            prefixIcon: Icons.add,
            isLoading: isSubmitting,
            onPressed: floatingActionButtonOnPressed,
            color: isDeleting ? Colors.grey : null,
          ),

        ]

      ],
    );

  }

  /// Action to be called when the floating action button is pressed
  void floatingActionButtonOnPressed() {

    /// If we have disabled the floating action button, then do nothing
    if(disableFloatingActionButton) return;

    /// If we are viewing a single transaction
    if(isViewingTransaction) {

      /// Change to the transactions view
      changeTransactionContentView(TransactionContentView.viewingTransactions);

    /// If we are viewing multiple transactions
    }else if(isViewingTransactions) {

      changeTransactionContentView(TransactionContentView.requestPayment);

    }

  }

  /// Called when the transaction filter has been changed,
  /// such as changing from "Paid" to "Pending Payment"
  void onSelectedTransactionFilter(String transactionFilter) {
    setState(() => this.transactionFilter = transactionFilter);
  }

  /// Called to change the view to the specified view
  void changeTransactionContentView(TransactionContentView transactionContentView) {
    setState(() => this.transactionContentView = transactionContentView);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Stack(
        children: [
          AnimatedSwitcher(
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            duration: const Duration(milliseconds: 500),
            child: Column(
              key: ValueKey(transactionContentView.name),
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                
                /// Wrap Padding around the following:
                /// Title, Subtitle, Filters
                Padding(
                  padding: EdgeInsets.only(top: 20 + topPadding, left: 32, bottom: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    
                      /// Title
                      CustomTitleMediumText(title, padding: const EdgeInsets.only(bottom: 8),),
                      
                      /// Subtitle
                      AnimatedSwitcher(
                        switchInCurve: Curves.easeIn,
                        switchOutCurve: Curves.easeOut,
                        duration: const Duration(milliseconds: 500),
                        child: Align(
                          key: ValueKey(subtitle),
                          alignment: Alignment.centerLeft,
                          child: CustomBodyText(subtitle),
                        )
                      ),
                  
                      //  Filter
                      if(isViewingTransactions) OrderTransactionFilters(
                        order: order,
                        paidByUser: paidByUser,
                        key: orderPayingUserTransactionFiltersState,
                        transactionFilter: transactionFilter,
                        onSelectedTransactionFilter: onSelectedTransactionFilter,
                      ),
                      
                    ],
                  ),
                ),
          
                /// Content
                Expanded(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    alignment: Alignment.topCenter,
                    width: double.infinity,
                    color: Colors.white,
                    child: content,
                  ),
                )
            
              ],
            ),
          ),
  
          /// Expand Icon
          if(!showingFullPage) Positioned(
            top: 8,
            right: 50,
            child: IconButton(
              icon: const Icon(Icons.open_in_full_rounded, size: 24, color: Colors.grey),
              onPressed: () {
                
                /// Close the Modal Bottom Sheet
                Get.back();
                
                /// Navigate to the page
                Get.toNamed(OrderTransactionsPage.routeName);
              
              }
            ),
          ),
  
          /// Cancel Icon
          Positioned(
            right: 10,
            top: 8 + topPadding,
            child: IconButton(
              icon: Icon(Icons.cancel, size: 28, color: Theme.of(context).primaryColor,),
              onPressed: () => Get.back()
            ),
          ),
  
          /// Floating Button (show if provided)
          AnimatedPositioned(
            right: 10,
            duration: const Duration(milliseconds: 500),
            top: (isViewingTransactions ? 112 : 56) + topPadding,
            child: floatingActionButton,
          )
        ],
      ),
    );
  }
}