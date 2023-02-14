import 'package:flutter/material.dart';
import '../search_content.dart';

class SearchPage extends StatefulWidget {

  static const routeName = 'SearchPage';

  const SearchPage({
    super.key,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SearchContent(
        showingFullPage: true
      ),
    );
  }
}