import '../../../../stores/providers/store_provider.dart';
import '../../../../stores/models/shoppable_store.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../followers_content.dart';

class FollowersPage extends StatefulWidget {

  static const routeName = 'FollowersPage';

  const FollowersPage({
    super.key,
  });

  @override
  State<FollowersPage> createState() => _FollowersPageState();
}

class _FollowersPageState extends State<FollowersPage> {

  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  ShoppableStore get store => storeProvider.store!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FollowersContent(
        store: store,
        showingFullPage: true
      ),
    );
  }
}