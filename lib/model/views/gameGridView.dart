import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gamer_grove/model/widgets/gamePreview.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import '../../repository/igdb/IGDBApiService.dart';
import '../igdb_models/game.dart';
import '../widgets/customDialog.dart';

class GameGridView extends StatelessWidget {
  final List<Game> collectionGames;

  GameGridView({
    required this.collectionGames,
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
          final game = collectionGames[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GamePreviewView(
              game: game,
              isCover: true,
              buildContext: context,
            ),
          );
        },
        childCount: collectionGames.length,
      ),
    );
  }
}

class AllGamesGridScreen extends StatefulWidget {
  static Route route(List<Game> game, BuildContext context, String appBarText) {
    return MaterialPageRoute(
      builder: (context) => AllGamesGridScreen(
        games: game,
        appBarText: appBarText,
      ),
    );
  }

  final List<Game> games;
  final String appBarText;

  AllGamesGridScreen({required this.games, required this.appBarText});

  @override
  _AllGamesGridScreenState createState() => _AllGamesGridScreenState();
}

class _AllGamesGridScreenState extends State<AllGamesGridScreen> {
  List<Game> sortedGames = [];
  String selectedSortOption = 'Rating';
  bool isAscending = true;

  @override
  void initState() {
    sortedGames = List.from(widget.games);
    super.initState();
  }

  void sortGames(String sortBy) {
    setState(() {
      if (selectedSortOption == sortBy) {
        isAscending = !isAscending;
      } else {
        isAscending = true;
        selectedSortOption = sortBy;
      }
      switch (sortBy) {
        case 'Rating':
          sortedGames.sort((a, b) => isAscending
              ? a.totalRating!.compareTo(b.totalRating!)
              : b.totalRating!.compareTo(a.totalRating!));
          break;
        case 'Name':
          sortedGames.sort((a, b) => isAscending
              ? a.name!.compareTo(b.name!)
              : b.name!.compareTo(a.name!));
          break;
        case 'Release Date':
          sortedGames.sort((a, b) => isAscending
              ? a.firstReleaseDate!.compareTo(b.firstReleaseDate!)
              : b.firstReleaseDate!.compareTo(a.firstReleaseDate!));
          break;
      }
    });
  }

  Widget buildSortButton(String sortBy, StateSetter setState) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: GlassContainer(
        blur: 10,
        color: Theme.of(context).colorScheme.background.withOpacity(.8),
        child: TextButton(
          onPressed: () {
            setState(() {
              sortGames(sortBy);
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedSortOption == sortBy ? ' $sortBy' : sortBy,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontWeight: selectedSortOption == sortBy
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              GlassContainer(
                color: Theme.of(context).colorScheme.tertiary,
                borderRadius: BorderRadius.circular(90),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    size: selectedSortOption == sortBy
                        ? 30 : 20,
                    color: Theme.of(context).colorScheme.onTertiary,
                    selectedSortOption == sortBy
                        ? (isAscending ? Icons.arrow_upward : Icons.arrow_downward)
                        : Icons.arrow_upward,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showSortOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          title: 'Sort by',
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildSortButton('Rating', setState),
                  buildSortButton('Name', setState),
                  buildSortButton('Release Date', setState),
                ],
              );
            },
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Anwenden'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(child: Text(widget.appBarText)),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              showSortOptionsDialog(context);
            },
          ),
        ],
      ),
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          GameGridView(
            collectionGames: sortedGames,
          ),
        ],
      ),
    );
  }
}

