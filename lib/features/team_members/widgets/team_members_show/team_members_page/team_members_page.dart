import '../../../../stores/providers/store_provider.dart';
import '../../../../stores/models/shoppable_store.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../team_members_content.dart';

class TeamMembersPage extends StatefulWidget {

  static const routeName = 'TeamMembersPage';

  const TeamMembersPage({
    super.key,
  });

  @override
  State<TeamMembersPage> createState() => _TeamMembersPageState();
}

class _TeamMembersPageState extends State<TeamMembersPage> {

  StoreProvider get storeProvider => Provider.of<StoreProvider>(context, listen: false);
  ShoppableStore get store => storeProvider.store!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TeamMembersContent(
        store: store,
        showingFullPage: true
      ),
    );
  }
}