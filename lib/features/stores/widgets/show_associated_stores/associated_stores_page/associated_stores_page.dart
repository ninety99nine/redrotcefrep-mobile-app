import '../associated_stores_content.dart';
import 'package:flutter/material.dart';

class AssociatedStoresPage extends StatefulWidget {

  static const routeName = 'AssociatedStoresPage';

  const AssociatedStoresPage({
    super.key,
  });

  @override
  State<AssociatedStoresPage> createState() => _AssociatedStoresPageState();
}

class _AssociatedStoresPageState extends State<AssociatedStoresPage> {

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: AssociatedStoresContent(
        showingFullPage: true
      ),
    );
  }
}