import '../../../../../core/shared_widgets/text/custom_body_text.dart';
import '../../../stores/models/shoppable_store.dart';
import 'package:flutter/material.dart';

class OrderCreate extends StatefulWidget {
  
  final ShoppableStore store;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final void Function(bool) onLoading;
  final void Function() onCreatedOrder;

  const OrderCreate({
    super.key,
    required this.store,
    required this.onLoading,
    required this.onCreatedOrder,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.only(top: 0.0),
  });

  @override
  State<OrderCreate> createState() => _OrderCreateState();
}

class _OrderCreateState extends State<OrderCreate> {

  GlobalKey<FormState> formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: widget.margin,
        padding: widget.padding,
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [

              CustomBodyText('Create Order'),

            ],
          )
        ),
      ),
    );
  }
}