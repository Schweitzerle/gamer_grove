import 'package:data_table_2/data_table_2.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:gamer_grove/model/igdb_models/game.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../igdb_models/multiplayer_mode.dart';
import '../igdb_models/platform.dart';
import '../igdb_models/release_date.dart';

class PlatformView extends StatelessWidget {
  final Game game;
  final Color color;

  const PlatformView({Key? key, required this.game, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final luminance = color.computeLuminance();
    final targetLuminance = 0.5;

    final adjustedIconColor =
    luminance > targetLuminance ? Colors.black : Colors.white;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: game.platforms!.map((platform) {
              return PlatformCard(
                platform: platform,
                releaseDates: game.releaseDates
                        ?.where((date) => date.platform?.id == platform.id)
                        .toList() ??
                    [],
                multiplayerModes: game.multiplayerModes
                        ?.where((mode) => mode.platform?.id == platform.id)
                        .toList() ??
                    [], color: color,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class PlatformCard extends StatefulWidget {
  final PlatformIGDB? platform;
  final List<ReleaseDate>? releaseDates;
  final List<MultiplayerMode>? multiplayerModes;
  final Color color;

  PlatformCard({
    required this.platform,
    required this.releaseDates,
    required this.multiplayerModes, required this.color,
  });

  @override
  _PlatformCardState createState() => _PlatformCardState();
}

class _PlatformCardState extends State<PlatformCard> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQueryHeight = MediaQuery.of(context).size.height;
    final mediaQueryWidth = MediaQuery.of(context).size.width;

    final luminance = widget.color.computeLuminance();
    final targetLuminance = 0.5;

    final adjustedIconColor =
    luminance > targetLuminance ? Colors.black : Colors.white;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: mediaQueryWidth * 0.7,
        height: mediaQueryHeight * .35,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: widget.color,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Bild der Plattform
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: mediaQueryWidth *.24,
                    height: mediaQueryWidth *.24,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.black,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          // Bild des Unternehmens mit ShaderMask
                          if (widget.platform!.platformLogo != null && widget.platform!.platformLogo!.url != null)
                            ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                    // Dunkelheit des Gradients anpassen
                                  ],
                                ).createShader(bounds);
                              },
                              blendMode: BlendMode.darken,
                              child: CachedNetworkImage(
                                imageUrl: widget.platform!.platformLogo!.url!,
                                width: mediaQueryWidth *.24,
                                height: mediaQueryWidth *.24,
                                fit: BoxFit.contain, // Bildgröße anpassen
                              ),
                            ),
                          // Name des Unternehmens
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 2),
                              child: FittedBox(
                                child: Text(
                                  widget.platform?.name ?? "",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (widget.releaseDates != null &&
                      widget.releaseDates!.isNotEmpty)
                    _buildReleaseDates("Release Dates", widget.releaseDates!,adjustedIconColor),
                ],
              ),
            ),

              _buildDataTable("Multiplayer Modes", widget.multiplayerModes!, adjustedIconColor),
          ],
        ),
      ),
    );
  }

  Widget _buildReleaseDates(String title, List<ReleaseDate> dates, Color color) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: dates.map((date) {
              return Text(
                "${date.human}",
                style: TextStyle(color: color),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(String title, List<MultiplayerMode> data, Color color) {
    return Expanded(
      flex: 3,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            widget.multiplayerModes != null &&
                widget.multiplayerModes!.isNotEmpty ? 
              Flexible(
              child: DataTable2(
                columns: [
                  DataColumn2(
                    label: Text('Mode'),
                    size: ColumnSize.S,
                  ),
                  DataColumn(
                    label: Text('Value'),
                  ),
                ],
                rows: [
                  DataRow(cells: [
                    DataCell(Flexible(child: Text('Campaign Coop', style: TextStyle(color: color),))),
                    DataCell(data.first.campaignCoop != null
                        ? Icon(data.first.campaignCoop!
                            ? Icons.check
                            : Icons.close)
                        : Text('')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('Dropin', style: TextStyle(color: color),)),
                    DataCell(data.first.dropin != null
                        ? Icon(data.first.dropin! ? Icons.check : Icons.close)
                        : Text('')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('LAN Coop', style: TextStyle(color: color),)),
                    DataCell(data.first.lanCoop != null
                        ? Icon(data.first.lanCoop! ? Icons.check : Icons.close)
                        : Text('')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('Offline Coop', style: TextStyle(color: color),)),
                    DataCell(data.first.offlineCoop != null
                        ? Icon(
                            data.first.offlineCoop! ? Icons.check : Icons.close)
                        : Text('')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('Offline Coop Max', style: TextStyle(color: color),)),
                    DataCell(data.first.offlineCoopMax != null
                        ? Text(data.first.offlineCoopMax!.toString())
                        : Text('N/A')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('Offline Max', style: TextStyle(color: color),)),
                    DataCell(data.first.offlineMax != null
                        ? Text(data.first.offlineMax!.toString())
                        : Text('N/A')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('Online Coop', style: TextStyle(color: color),)),
                    DataCell(data.first.onlineCoop != null
                        ? Icon(
                            data.first.onlineCoop! ? Icons.check : Icons.close)
                        : Text('')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('Online Coop Max', style: TextStyle(color: color),)),
                    DataCell(data.first.onlineCoopMax != null
                        ? Text(data.first.onlineCoopMax!.toString())
                        : Text('N/A')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('Online Max', style: TextStyle(color: color),)),
                    DataCell(data.first.onlineMax != null
                        ? Text(data.first.onlineMax!.toString())
                        : Text('N/A')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('Split Screen', style: TextStyle(color: color),)),
                    DataCell(data.first.splitScreen != null
                        ? Icon(
                            data.first.splitScreen! ? Icons.check : Icons.close)
                        : Text('')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('Split Screen Online', style: TextStyle(color: color),)),
                    DataCell(data.first.splitScreenOnline != null
                        ? Icon(data.first.splitScreenOnline!
                            ? Icons.check
                            : Icons.close)
                        : Text('')),
                  ]),
                ],
              ),
            ) : Padding(
              padding: const EdgeInsets.all(28.0),
              child: Center(child: Text('No information available', style: TextStyle(color: color),),),
            ),
          ],
        ),
      ),
    );
  }
}
