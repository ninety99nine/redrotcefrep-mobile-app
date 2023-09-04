import 'package:bonako_demo/features/transactions/widgets/order_transactions/order_transactions_in_vertical_list_view_infinite_scroll.dart';
import 'package:bonako_demo/features/stores/widgets/store_cards/store_card/primary_section_content/store_logo.dart';
import 'package:bonako_demo/features/transactions/widgets/order_transactions/order_transaction_filters.dart';
import '../../../../core/shared_widgets/button/custom_elevated_button.dart';
import '../../../../core/shared_widgets/text/custom_title_medium_text.dart';
import 'package:bonako_demo/features/transactions/models/transaction.dart';
import '../../../../core/shared_widgets/text/custom_body_text.dart';
import 'package:bonako_demo/features/orders/models/order.dart';
import 'order_transactions_page/order_transactions_page.dart';
import '../../../stores/providers/store_provider.dart';
import '../../../stores/models/shoppable_store.dart';
import '../../enums/transaction_enums.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class OrderTransactionsContent extends StatefulWidget {
  
  final Order order;
  final bool showingFullPage;
  final Transaction? transaction;
  final TransactionContentView? transactionContentView;

  const OrderTransactionsContent({
    super.key,
    this.transaction,
    required this.order,
    this.transactionContentView,
    this.showingFullPage = false,
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
  late TransactionContentView transactionContentView;

  /// This allows us to access the state of UpdateStoreForm widget using a Global key. 
  /// We can then fire methods of the child widget from this current Widget state. 
  /// Reference: https://www.youtube.com/watch?v=uvpaZGNHVdI
  final GlobalKey<OrderTransactionFiltersState> orderTransactionFiltersState = GlobalKey<OrderTransactionFiltersState>();

  Order get order => widget.order;
  bool get isPaid => order.attributes.isPaid;
  double get topPadding => showingFullPage ? 32 : 0;
  bool get showingFullPage => widget.showingFullPage;
  ShoppableStore get store => order.relationships.store!;
  bool get hasTransactions => order.transactionsCount != 0;
  String get totalTransactions => order.transactionsCount!.toString();
  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  bool get isViewingRequestPayment => transactionContentView == TransactionContentView.requestPayment;
  bool get isViewingTransaction => transactionContentView == TransactionContentView.viewingTransaction;
  bool get isViewingTransactions => transactionContentView == TransactionContentView.viewingTransactions;
  String get subtitle {
    if(isViewingRequestPayment) {
      return 'Pay using BonakoPay';
    }else if(isViewingTransactions) {
      return 'Showing ${transactionFilter.toLowerCase()} coupons';
    }else{
      return 'Transaction #${transaction!.attributes.number}';
    }
  }

  @override
  void initState() {
    super.initState();
    transaction = widget.transaction;

    if(widget.transactionContentView != null) {

      transactionContentView = widget.transactionContentView!;

    }else{
     
      transactionContentView = hasTransactions ? TransactionContentView.viewingTransactions : TransactionContentView.requestPayment; 
    
    }
  }

  /// Content to show based on the specified view
  Widget get content {
      
    return OrderTransactionsInVerticalListViewInfiniteScroll(
      order: order,
      transactionFilter: transactionFilter,
      onSelectedTransaction: onSelectedTransaction,
      orderTransactionFiltersState: orderTransactionFiltersState
    );
    
  }

  void onSelectedTransaction(Transaction transaction){
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

        if( isViewingTransactions && !isPaid ) ...[

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

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          //  Store Logo
                          StoreLogo(store: store, radius: 24),

                          /// Spacer
                          const SizedBox(width: 8,),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                
                              /// Title
                              CustomTitleMediumText(store.name, overflow: TextOverflow.ellipsis, margin: const EdgeInsets.only(top: 4, bottom: 4),),
                              
                              /// Subtitle
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: CustomBodyText('Pay using BonakoPay'),
                              )

                            ],
                          )

                        ],
                      ),

                      /// Spacer
                      const SizedBox(height: 4,),
                  
                      //  Filter
                      if(isViewingTransactions) OrderTransactionFilters(
                        order: order,
                        key: orderTransactionFiltersState,
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
                Navigator.of(context).pop();

                /// Set the store
                storeProvider.setStore(store);
                
                /// Navigate to the page
                Navigator.of(context).pushNamed(OrderTransactionsPage.routeName);
              
              }
            ),
          ),
  
          /// Cancel Icon
          Positioned(
            right: 10,
            top: 8 + topPadding,
            child: IconButton(
              icon: Icon(Icons.cancel, size: 28, color: Theme.of(context).primaryColor,),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
  
          /// Floating Button (show if provided)
          AnimatedPositioned(
            right: 10,
            duration: const Duration(milliseconds: 500),
            top: (isViewingTransactions ? 120 : 56) + topPadding,
            child: floatingActionButton,
          )
        ],
      ),
    );
  }
}