import 'package:flutter/material.dart';
import 'package:gamer_grove/model/igdb_models/language_support.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';

/*  @override
  Widget build(BuildContext context) {
    // Gruppierung von LanguageSupports nach Sprache
    Map<int, List<LanguageSupport>> groupedSupports = {};
    languageSupports.forEach((support) {
      if (!groupedSupports.containsKey(support.language?.id)) {
        groupedSupports[support.language?.id ?? 0] = [];
      }
      groupedSupports[support.language?.id ?? 0]?.add(support);
    });

    // Erstellung von Zeilen für jede Sprache
    List<DataRow> rows = [];
    groupedSupports.forEach((languageId, supports) {
      // Erstellung von Sets für jedes Language Support Type
      Set<String> interfaceSet = {};
      Set<String> audioSet = {};
      Set<String> subtitlesSet = {};

      // Durchlaufen der Language Supports und Hinzufügen der Support Typen zu den Sets
      supports.forEach((support) {
        switch (support.languageSupportType?.name) {
          case 'Interface':
            interfaceSet.add('✔️');
            break;
          case 'Audio':
            audioSet.add('✔️');
            break;
          case 'Subtitles':
            subtitlesSet.add('✔️');
            break;
          default:
            break;
        }
      });

      // Debug-Ausgabe
      print('Subtitles Set for Language ${supports.first.language?.name}: $subtitlesSet');

      // Konvertierung der Sets in Zeichenfolgen
      String interfaceText = interfaceSet.join(', ');
      String audioText = audioSet.join(', ');
      String subtitlesText = subtitlesSet.join(', ');

      // Erstellung von DataRow für jede Sprache mit unterstützten Typen
      DataRow row = DataRow(cells: [
        DataCell(Text(supports.first.language?.name ?? '')),
        DataCell(Text(interfaceText)),
        DataCell(Text(audioText)),
        DataCell(Text(subtitlesText)), // Hier fügen wir die Untertitel-Zeichenfolge hinzu
      ]);

      rows.add(row);
    });

    return DataTable(
      columns: [
        DataColumn(label: Text('Language')),
        DataColumn(label: Text('Interface')),
        DataColumn(label: Text('Audio')),
        DataColumn(label: Text('Subtitles')),
      ],
      rows: rows,
    );
  }
}*/

import 'package:flutter/material.dart';
import 'package:gamer_grove/model/igdb_models/language_support.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: widget.color
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SfDataGridTheme(
          data: SfDataGridThemeData(
            headerColor: widget.color, // Color for header
            gridLineColor: Colors.grey, // Color for grid lines
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
                    child: Text('Language'),
                  ),
                ),
                GridColumn(
                  columnName: 'interface',
                  label: Container(
                    padding: EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: Text('Interface'),
                  ),
                ),
                GridColumn(
                  columnName: 'audio',
                  label: Container(
                    padding: EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: Text('Audio'),
                  ),
                ),
                GridColumn(
                  columnName: 'subtitles',
                  label: Container(
                    padding: EdgeInsets.all(8.0),
                    alignment: Alignment.center,
                    child: Text('Subtitles'),
                  ),
                ),
              ],
          ),
        ),
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
          child: Text(dataGridCell.value.toString()),
        );
      }).toList(),
    );
  }
}

