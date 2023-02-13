import '../../../../core/shared_widgets/text/custom_body_text.dart';
import 'package:flutter/material.dart';

class CommunitiesPageContent extends StatefulWidget {
  const CommunitiesPageContent({super.key});

  @override
  State<CommunitiesPageContent> createState() => _CommunitiesPageContentState();
}

class _CommunitiesPageContentState extends State<CommunitiesPageContent> with SingleTickerProviderStateMixin /*, AutomaticKeepAliveClientMixin */ {

  /*
   *  Reason for using AutomaticKeepAliveClientMixin
   * 
   *  We want to preserve the state of this Widget when using the TabBarView()
   *  to swipe between the My Stores, Following and Recent Visits. The natural
   *  Flutter behaviour when swipping between these tabs is to destroy the
   *  current tab content while switching to the new tab content. By using
   *  the AutomaticKeepAliveClientMixin, we can preserve the state so that
   *  the current state data is not destroyed. When switching back to this
   *  tab, the content will be exactly as it was before switching away.
   * 
   *  Reference: https://stackoverflow.com/questions/55850686/why-is-flutter-disposing-my-widget-state-object-in-a-tabbed-interface
   * 
   *  @override
   *  bool wantKeepAlive = true;
  */

  @override
  Widget build(BuildContext context) {
    return const CustomBodyText('Communities');
  }
}
