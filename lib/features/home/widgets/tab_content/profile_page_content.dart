import '../../../../core/shared_widgets/text/custom_title_medium_text.dart';
import '../../../authentication/repositories/auth_repository.dart';
import '../../../profile/widgets/user_profile/user_profile_avatar.dart';
import '../../../authentication/providers/auth_provider.dart';
import '../../../../core/shared_models/user.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class ProfilePageContent extends StatefulWidget {

  const ProfilePageContent({super.key});

  @override
  State<ProfilePageContent> createState() => _ProfilePageContentState();
}

class _ProfilePageContentState extends State<ProfilePageContent> {

  User get user => authProvider.user!;
  AuthRepository get authRepository => authProvider.authRepository;
  AuthProvider get authProvider => Provider.of<AuthProvider>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              //  User Profile
              UserProfile(user: user),

              //  Re-order
              const CustomTitleMediumText('2 communities'),
        
              //  Re-order
              const CustomTitleMediumText('joined @'),
        
              //  Re-order
              const CustomTitleMediumText('my stores'),
        
              //  Spacer
              const SizedBox(height: 24),
        
              //  My Orders
              const CustomTitleMediumText('Home & Work Address (Add / Edit)'),
        
              //  Spacer
              const SizedBox(height: 24),
        
              //  My Orders
              const CustomTitleMediumText('My Orders'),
        
              //  Spacer
              const SizedBox(height: 24),
        
              //  Re-order
              const CustomTitleMediumText('Re-order'),
        
              //  Spacer
              const SizedBox(height: 24),
        
              //  Recent Visits
              const CustomTitleMediumText('Recent Visits'),
        
              //  Spacer
              const SizedBox(height: 24),
        
              //  Re-order
              const CustomTitleMediumText('Following: Local Business I Support'),

            ],
          ),
        ),
      ),
    );
  }
}