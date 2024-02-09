import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:gamer_grove/model/widgets/gamePreview.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../repository/igdb/IGDBApiService.dart';
import '../igdb_models/game.dart';

class GameGridPaginationView extends StatefulWidget {
  final PagingController<int, Game> pagingController;
  final ScrollController scrollController;

  GameGridPaginationView({
    required this.pagingController, required this.scrollController,
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
              childAspectRatio: .7,
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8
            ),
            pagingController: widget.pagingController,
            builderDelegate: PagedChildBuilderDelegate<Game>(
              itemBuilder: (context, game, index) {
                return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                  child: Center(
                    child: GamePreviewView(
                      game: game,
                      isCover: false, buildContext: context,
                    ),
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
