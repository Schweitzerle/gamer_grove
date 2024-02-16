import 'package:flutter/material.dart';
import 'package:gamer_grove/model/igdb_models/language_support.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class LanguageSupportTable extends StatefulWidget {
  final List<LanguageSupport> languageSupports;
  final Color color;

  LanguageSupportTable({required this.languageSupports, required this.color});

  @override
  _LanguageSupportTableState createState() => _LanguageSupportTableState();
}

class _LanguageSupportTableState extends State<LanguageSupportTable> {
  late LanguageDataSource languageDataSource;

  @override
  void initState() {
    super.initState();
    languageDataSource =
        LanguageDataSource(languageSupports: widget.languageSupports);
  }

  @override
  Widget build(BuildContext context) {
    final luminance = widget.color.computeLuminance();
    final targetLuminance = 0.5;

    final adjustedIconColor =
    luminance > targetLuminance ? Colors.black : Colors.white;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: widget.color.withOpacity(.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 8, right: 8),
            child: Text(
              'Supported Languages',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: adjustedIconColor,
              ),
            ),
          ),
          SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SfDataGridTheme(
              data: SfDataGridThemeData(
                headerColor: widget.color, // Color for header
                gridLineColor: adjustedIconColor, // Color for grid lines
              ),
              child: SfDataGrid(
                gridLinesVisibility: GridLinesVisibility.horizontal,
                verticalScrollPhysics: BouncingScrollPhysics(),
                source: languageDataSource,
                  columnWidthMode: ColumnWidthMode.fill,
                  columns: <GridColumn>[
                    GridColumn(
                      columnName: 'language',
                      label: Container(
                        padding: EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: Text('Language', style: TextStyle(color: adjustedIconColor),),
                      ),
                    ),
                    GridColumn(
                      columnName: 'interface',
                      label: Container(
                        padding: EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: Text('Interface', style: TextStyle(color: adjustedIconColor),),
                      ),
                    ),
                    GridColumn(
                      columnName: 'audio',
                      label: Container(
                        padding: EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: Text('Audio', style: TextStyle(color: adjustedIconColor),),
                      ),
                    ),
                    GridColumn(
                      columnName: 'subtitles',
                      label: Container(
                        padding: EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: Text('Subtitles', style: TextStyle(color: adjustedIconColor),),
                      ),
                    ),
                  ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LanguageDataSource extends DataGridSource {
  LanguageDataSource({required List<LanguageSupport> languageSupports}) {
    _dataGridRows = [];

    // Map zur Verfolgung der unterstützten Typen für jedes Land
    Map<String, Map<String, bool>> supportMap = {};

    // Durchlaufen der LanguageSupport-Liste und Hinzufügen der unterstützten Typen zu der Map
    for (var support in languageSupports) {
      String languageName = support.language?.name ?? '';
      String supportTypeName = support.languageSupportType?.name ?? '';

      if (!supportMap.containsKey(languageName)) {
        supportMap[languageName] = {
          'Interface': false,
          'Audio': false,
          'Subtitles': false,
        };
      }

      // Markieren des unterstützten Typs für das aktuelle Land
      supportMap[languageName]![supportTypeName] = true;
    }

    // Generieren von DataGridRows für jedes Land basierend auf der Map
    supportMap.forEach((languageName, supportTypes) {
      _dataGridRows.add(DataGridRow(
        cells: [
          DataGridCell<String>(columnName: 'language', value: languageName),
          DataGridCell<String>(
            columnName: 'interface',
            value: supportTypes['Interface'] == true ? '✔️' : '',
          ),
          DataGridCell<String>(
            columnName: 'audio',
            value: supportTypes['Audio'] == true ? '✔️' : '',
          ),
          DataGridCell<String>(
            columnName: 'subtitles',
            value: supportTypes['Subtitles'] == true ? '✔️' : '',
          ),
        ],
      ));
    });
  }

  late List<DataGridRow> _dataGridRows;

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        return Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(8.0),
          child: Text(dataGridCell.value.toString(), style: TextStyle(color: Colors.white),),
        );
      }).toList(),
    );
  }
}

