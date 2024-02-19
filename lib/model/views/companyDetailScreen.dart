import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:gamer_grove/model/igdb_models/company.dart';
import 'package:gamer_grove/model/igdb_models/company_website.dart';
import 'package:gamer_grove/model/widgets/company_view.dart';
import 'package:gamer_grove/model/widgets/infoRow.dart';
import 'package:gamer_grove/model/widgets/toggleSwitchesCompanyDetailScreen.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';

import 'package:intl/intl.dart';
import 'package:iso_countries/iso_countries.dart';
import 'package:motion/motion.dart';
import 'package:palette_generator/palette_generator.dart';

import '../../repository/igdb/IGDBApiService.dart';
import '../igdb_models/website.dart';

class CompanyDetailScreen extends StatefulWidget {
  static Route route(Company company, BuildContext context) {
    return MaterialPageRoute(
      builder: (context) => CompanyDetailScreen(
        company: company,
        context: context,
      ),
    );
  }

  final Company company;
  final BuildContext context;

  CompanyDetailScreen({required this.company, required this.context});

  @override
  _CompanyDetailScreenState createState() => _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends State<CompanyDetailScreen> {
  late Color colorPalette;
  late Color lightColor;
  late Color darkColor;
  late PaletteColor color;
  bool isColorLoaded = false;
  List<Company> companies = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      colorPalette = Theme.of(widget.context).colorScheme.inversePrimary;
      lightColor = Theme.of(widget.context).colorScheme.primary;
      darkColor = Theme.of(widget.context).colorScheme.background;
    });
    initialize();
  }

  Future<void> initialize() async {
    await Future.wait([getColorPalette(), getIGDBData()]);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> getIGDBData() async {
    final apiService = IGDBApiService();
    try {
      final body = '''
      query companies "Game Details" {
fields country,description,developed.*, developed.cover.*, logo.*, name, parent.*, parent.logo.*, published.*, published.cover.*, start_date, url, websites.*; 
w id = ${widget.company.id};      
        limit 1;
      };
    };
    ''';

      final List<dynamic> response =
          await apiService.getIGDBData(IGDBAPIEndpointsEnum.multiquery, body);

      setState(() {
        // Extract data for game details
        final gameResponse = response.firstWhere(
            (item) => item['name'] == 'Game Details',
            orElse: () => null);
        if (gameResponse != null) {
          companies = apiService.parseResponseToCompany(gameResponse['result']);
          if (companies[0].websites != null) {
            companies[0]
                .websites!
                .add(CompanyWebsite(id: -1, url: companies[0].url!));
          } else {
            companies[0].websites = [
              CompanyWebsite(id: -1, url: companies[0].url!)
            ];
          }
        }
      });
    } catch (e, stackTrace) {
      print('Error: $e');
      print('Stack Trace: $stackTrace');
    }
  }

  Future<void> getColorPalette() async {
    if (widget.company.logo!.url != null) {
      final PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(
        NetworkImage('${widget.company.logo!.url}'),
        size: Size(100, 150), // Adjust the image size as needed
        maximumColorCount: 10, // Adjust the maximum color count as needed
      );
      setState(() {
        color = paletteGenerator.dominantColor!;
        colorPalette = paletteGenerator.dominantColor?.color ??
            Theme.of(widget.context).colorScheme.inversePrimary;
        lightColor = paletteGenerator.lightVibrantColor?.color ??
            Theme.of(widget.context).colorScheme.primary;
        darkColor = paletteGenerator.darkVibrantColor?.color ??
            Theme.of(widget.context).colorScheme.background;
        isColorLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;

    final coverScaleHeight = mediaQueryHeight / 5;
    final coverScaleWidth = coverScaleHeight;
    final bannerScaleHeight = mediaQueryHeight * 0.3;

    final coverPaddingScaleHeight = mediaQueryHeight * 0.12;

    final containerBackgroundColor = colorPalette.darken(10);

    return Scaffold(
      body: Container(
        height: mediaQueryHeight,
        width: mediaQueryWidth,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.0, 0.9), // Start at the middle left
            end: Alignment(0.0, 0.4), // End a little above the middle
            colors: [
              colorPalette.darken(20),
              colorPalette.lighten(10),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                alignment: Alignment.topLeft,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        left: 16.0, right: 16, top: coverPaddingScaleHeight),
                    child: Row(
                      children: [
                        // Cover image
                        Motion(
                          glare: GlareConfiguration(
                            color: colorPalette.lighten(20),
                            minOpacity: 0,
                          ),
                          shadow: const ShadowConfiguration(
                              color: Colors.black, blurRadius: 2, opacity: .2),
                          borderRadius: BorderRadius.circular(14),
                          child: SizedBox(
                            height: coverScaleHeight,
                            width: coverScaleWidth,
                            child: CompanyCard(
                              company: widget.company,
                              size: coverScaleHeight,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 16,
                        ),
                        // Additional Info Rows
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              widget.company.startDate != null
                                  ? InfoRow.buildInfoRow(
                                      CupertinoIcons.calendar_today,
                                      DateFormat('dd.MM.yyyy').format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              widget.company.startDate! *
                                                  1000)),
                                      containerBackgroundColor,
                                      Color(0xff9d94ff),
                                      false,
                                      context)
                                  : Container(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Text above GamePreviewView
                  Padding(
                    padding: EdgeInsets.only(
                        left: 16.0,
                        right: 16.0,
                        top: coverPaddingScaleHeight / 1.9),
                    child: FittedBox(
                      child: GlassContainer(
                        blur: 12,
                        shadowStrength: 10,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(14),
                        shadowColor: colorPalette,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: AnimatedTextKit(
                            animatedTexts: [
                              TypewriterAnimatedText(
                                widget.company.name!.isNotEmpty
                                    ? widget.company.name!
                                    : 'Loading...',
                                speed: Duration(milliseconds: 150),
                                textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                            isRepeatingAnimation: false,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: mediaQueryHeight * .01,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (companies.isNotEmpty)
                    CompanyInfoWidget(
                        company: companies[0], color: colorPalette),
                  if (companies.isNotEmpty)
                    CompanyGamesContainerSwitchWidget(
                      company: companies[0],
                      color: colorPalette,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
