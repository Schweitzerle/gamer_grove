import 'package:flutter/material.dart';
import 'package:gamer_grove/model/igdb_models/company.dart';
import 'package:gamer_grove/model/widgets/company_view.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:loading_indicator/loading_indicator.dart';

import '../widgets/shimmerGameItem.dart';

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
              firstPageProgressIndicatorBuilder:(_) => ShimmerItem.buildShimmerCompanyGridItem(context),
              newPageProgressIndicatorBuilder: (_) => const Center(
                child: Padding(
                  padding: EdgeInsets.all(18.0),
                  child: LoadingIndicator(
                    indicatorType: Indicator.pacman, /// Required, The loading type of the widget
                  ),
                ),
              ),
              itemBuilder: (context, game, index) {
                return CompanyCard(
                  company: game, size: 200,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
