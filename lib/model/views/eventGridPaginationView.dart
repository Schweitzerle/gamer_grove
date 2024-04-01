import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:gamer_grove/model/igdb_models/event.dart';
import 'package:gamer_grove/model/widgets/event_view.dart';
import 'package:gamer_grove/model/widgets/gamePreview.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:loading_indicator/loading_indicator.dart';
import '../../repository/igdb/IGDBApiService.dart';
import '../igdb_models/game.dart';
import '../widgets/customDialog.dart';
import '../widgets/shimmerGameItem.dart';

class EventGridPaginationView extends StatefulWidget {
  final PagingController<int, Event> pagingController;
  final ScrollController scrollController;

  EventGridPaginationView({
    required this.pagingController, required this.scrollController,
  });

  @override
  State<StatefulWidget> createState() => EventGridPaginationViewState();
}

class EventGridPaginationViewState extends State<EventGridPaginationView> {
  @override
  Widget build(BuildContext context) {
    final mediaQueryHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: PagedGridView<int, Event>(
            scrollController: widget.scrollController,
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 1.4,
              crossAxisCount: 2,
            ),
            pagingController: widget.pagingController,
            builderDelegate: PagedChildBuilderDelegate<Event>(
              firstPageProgressIndicatorBuilder:(_) => ShimmerItem.buildShimmerEventGridItem(context),
              newPageProgressIndicatorBuilder: (_) => const Center(
                child: Padding(
                  padding: EdgeInsets.all(18.0),
                  child: LoadingIndicator(
                    indicatorType: Indicator.pacman, /// Required, The loading type of the widget
                  ),
                ),
              ),
              itemBuilder: (context, game, index) {
                return Padding(
                    padding: const EdgeInsets.all(8.0),
                  child: EventUI(
                    event: game,
                    buildContext: context,
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
