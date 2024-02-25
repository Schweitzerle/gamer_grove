import 'package:clay_containers/widgets/clay_container.dart';
import 'package:flutter/material.dart';
import 'package:gamer_grove/model/igdb_models/company.dart';
import 'package:gamer_grove/model/igdb_models/event.dart';
import 'package:gamer_grove/model/widgets/company_view.dart';
import 'package:gamer_grove/model/widgets/event_view.dart';
import 'package:gamer_grove/model/widgets/gamePreview.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:loading_indicator/loading_indicator.dart';
import '../../repository/igdb/IGDBApiService.dart';
import '../igdb_models/game.dart';
import '../widgets/customDialog.dart';

class CompanyGridPaginationView extends StatefulWidget {
  final PagingController<int, Company> pagingController;
  final ScrollController scrollController;

  CompanyGridPaginationView({
    required this.pagingController, required this.scrollController,
  });

  @override
  State<StatefulWidget> createState() => CompanyGridPaginationViewState();
}

class CompanyGridPaginationViewState extends State<CompanyGridPaginationView> {
  @override
  Widget build(BuildContext context) {
    final mediaQueryHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: PagedGridView<int, Company>(
            scrollController: widget.scrollController,
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 1,
              crossAxisCount: 2,
            ),
            pagingController: widget.pagingController,
            builderDelegate: PagedChildBuilderDelegate<Company>(
              firstPageProgressIndicatorBuilder:(_) => const Padding(
                padding: EdgeInsets.all(78.0),
                child: Center(
                  child: LoadingIndicator(
                      indicatorType: Indicator.pacman, /// Required, The loading type of the widget
                  ),
                ),
              ),
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
                  child: CompanyCard(
                    company: game, size: 200,
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
