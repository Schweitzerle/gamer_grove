import 'package:flutter/material.dart';
import 'package:gamer_grove/model/widgets/gamePreview.dart';
import '../../repository/igdb/IGDBApiService.dart';
import '../igdb_models/character.dart';
import '../igdb_models/game.dart';
import '../widgets/character_view.dart';

class CharacterGridView extends StatelessWidget {
  final List<Character> characters;

  CharacterGridView({
    required this.characters,
  });

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: .7,
          crossAxisCount: 2,
      ),
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final character = characters[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: CharacterView(character: character, buildContext: context)),
          );
        },
        childCount: characters.length,
      ),
    );
  }
}

class AllCharacterGridScreen extends StatelessWidget {
  static Route route(List<Character> characters, BuildContext context, String appBarText) {
    return MaterialPageRoute(
      builder: (context) => AllCharacterGridScreen(
        characters: characters, appBarText: appBarText,
      ),
    );
  }

  final List<Character> characters;
  final String appBarText;

  AllCharacterGridScreen({required this.characters, required this.appBarText});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(child: Text(appBarText)),
      ),
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          CharacterGridView(characters: characters,),
        ],
      ),
    );
  }
}
