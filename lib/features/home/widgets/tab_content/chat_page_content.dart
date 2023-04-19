import '../../../authentication/providers/auth_provider.dart';
import '../../../../core/shared_models/user.dart';
import '../../../chat/widgets/chat.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class ChatPageContent extends StatefulWidget {

  const ChatPageContent({super.key});

  @override
  State<ChatPageContent> createState() => _ChatPageContentState();
}

class _ChatPageContentState extends State<ChatPageContent> {

  User get user => authProvider.user!;
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    return const Chat();
  }
}