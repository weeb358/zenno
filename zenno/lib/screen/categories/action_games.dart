import 'package:flutter/material.dart';
import '../category_games.dart';

class ActionGamesScreen extends StatelessWidget {
  const ActionGamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CategoryGamesScreen(categoryName: 'ACTION');
  }
}