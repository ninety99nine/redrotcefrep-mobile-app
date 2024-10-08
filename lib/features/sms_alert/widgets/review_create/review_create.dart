import 'package:perfect_order/features/sms_alert/models/sms_alert.dart';
import 'package:flutter/material.dart';

class ReviewCreate extends StatefulWidget {
  
  final SmsAlert smsAlert;

  const ReviewCreate({
    super.key,
    required this.smsAlert,
  });

  @override
  State<ReviewCreate> createState() => _ReviewCreateState();
}

class _ReviewCreateState extends State<ReviewCreate> {
  
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [

      ],
    );
  }
}