import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:gamer_grove/model/firebase/firebaseUser.dart';
import 'package:gamer_grove/model/widgets/gamePreview.dart';
import 'package:gamer_grove/model/widgets/shimmerGameItem.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:loading_indicator/loading_indicator.dart';
import '../../repository/igdb/IGDBApiService.dart';
import '../igdb_models/game.dart';
import '../widgets/customDialog.dart';

class GameGridPaginationView extends StatefulWidget {
  final PagingController<int, Game> pagingController;
  final ScrollController scrollController;
  final FirebaseUserModel? otherModel;

  GameGridPaginationView({
    required this.pagingController, required this.scrollController, this.otherModel,
  });

  @override
  State<StatefulWidget> createState() => GameGridPaginationViewState();
}

class GameGridPaginationViewState extends State<GameGridPaginationView> {
  @override
  Widget build(BuildContext context) {
    final mediaQueryHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: PagedGridView<int, Game>(
            scrollController: widget.scrollController,
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: .72,
              crossAxisCount: 2,
            ),
            pagingController: widget.pagingController,
            builderDelegate: PagedChildBuilderDelegate<Game>(
              firstPageProgressIndicatorBuilder:(_) => ShimmerItem.buildShimmerGameGridItem(context),
              newPageProgressIndicatorBuilder: (_) => const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: LoadingIndicator(
                    indicatorType: Indicator.pacman, /// Required, The loading type of the widget
                  ),
                ),
              ),
              itemBuilder: (context, game, index) {
                return Padding(
                    padding: const EdgeInsets.all(6.0),
                  child: GamePreviewView(
                    game: game,
                    isCover: false, buildContext: context, needsRating: true, isClickable: true, otherUserModel: widget.otherModel,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class AllGamesGridPaginationScreen extends StatefulWidget {
  static Route route(String appBarText, String body, bool isAggregated, FirebaseUserModel? otherModel) {
    return MaterialPageRoute(
      builder: (context) =>
          AllGamesGridPaginationScreen(appBarText: appBarText, body: body, isAggregated: isAggregated, otherModel: otherModel,),
    );
  }

  final String appBarText;
  final String body;
  final bool isAggregated;
  final FirebaseUserModel? otherModel;

  AllGamesGridPaginationScreen({required this.appBarText, required this.body, required this.isAggregated, this.otherModel});

  @override
  _AllGamesGridPaginationScreenState createState() =>
      _AllGamesGridPaginationScreenState();
}

class _AllGamesGridPaginationScreenState
    extends State<AllGamesGridPaginationScreen> {
  late ScrollController _scrollController;
  late PagingController<int, Game> _pagingController;
  String query = "";
  late String selectedSortOption = 'Rating';
  late bool isAscending = true;
  String sorting = '';

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _pagingController =
        PagingController(firstPageKey: 0); // Change firstPageKey to 0
    _pagingController.addPageRequestListener((pageKey) {
      _fetchGamesPage(pageKey);
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _fetchGamesPage(int pageKey) async {
    try {
      final List<Game> games = await _fetchGames(pageKey);

      final isLastPage = games.isEmpty;

      if (isLastPage) {

        _pagingController.appendLastPage(games);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(games, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  Future<List<Game>> _fetchGames(int pageKey) async {
    final apiService = IGDBApiService();
    final offset = pageKey * 20;
    String body = '${widget.body} o $offset; ${sorting}';
    final response = await apiService.getIGDBData(
        IGDBAPIEndpointsEnum.games, body);

    final games = apiService.parseResponseToGame(response);
    return games;
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
                  buildSortButton(widget.isAggregated ? 'aggregated_rating' : 'total_rating', 'Rating', setState),
                  buildSortButton('name', 'Name', setState),
                  buildSortButton('first_release_date', 'Release Date', setState),
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
                setState(() {
                  sorting = 's ${selectedSortOption} ${isAscending ? 'asc' : 'desc'};';
                });
                _pagingController.refresh();
              },
              child: Text('Anwenden'),
            ),
          ],
        );
      },
    );
  }

  Widget buildSortButton(String sortBy, String buttonText, StateSetter setState) {
    bool isSelected = selectedSortOption == sortBy;
    bool isCurrentAscending = isSelected ? isAscending : true; // Set isAscending to true if not selected

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: GlassContainer(
        blur: 10,
        color: Theme.of(context).colorScheme.background.withOpacity(.8),
        child: TextButton(
          onPressed: () {
            setState(() {
              if (selectedSortOption == sortBy) {
                isAscending = !isAscending;
              } else {
                selectedSortOption = sortBy;
                if (selectedSortOption == 'my_rating') {

                }
                isAscending = true;
              }
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                buttonText,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              GlassContainer(
                color: Theme.of(context).colorScheme.tertiary,
                borderRadius: BorderRadius.circular(90),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(
                    size: isSelected ? 30 : 20,
                    color: Theme.of(context).colorScheme.onTertiary,
                    isSelected
                        ? (isCurrentAscending ? Icons.arrow_upward : Icons.arrow_downward)
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
      body: GameGridPaginationView(
        pagingController: _pagingController,
        scrollController: _scrollController, otherModel: widget.otherModel
      ),
    );
  }
}
