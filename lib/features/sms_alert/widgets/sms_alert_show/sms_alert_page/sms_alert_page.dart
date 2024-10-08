import 'package:perfect_order/features/sms_alert/models/sms_alert.dart';
import 'package:flutter/material.dart';
import '../sms_alert_content.dart';
import 'package:get/get.dart';

class SmsAlertPage extends StatefulWidget {

  static const routeName = 'SmsAlertPage';

  const SmsAlertPage({
    super.key,
  });

  @override
  State<SmsAlertPage> createState() => _SmsAlertPageState();
}

class _SmsAlertPageState extends State<SmsAlertPage> {

  SmsAlert? smsAlert;
  bool canShowFloatingActionButton = true;

  @override
  void initState() {
    
    super.initState();

    /// Get the route arguments
    final arguments = Get.arguments;

    /// Set the "smsAlert" (if provided)
    smsAlert = arguments['smsAlert'] as SmsAlert;

    /// Get the "canShowFloatingActionButton" (if provided)
    if(arguments.containsKey('canShowFloatingActionButton')) canShowFloatingActionButton = arguments['canShowFloatingActionButton'] as bool;

  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      /// Content of the page
      body: SmsAlertContent(
        showingFullPage: true,
        //  canShowFloatingActionButton: canShowFloatingActionButton
      ),
    );
  }
}