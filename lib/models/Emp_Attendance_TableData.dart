import 'package:flutter/material.dart';

class TableData extends StatelessWidget {
  final String title;
  final List<List<String>> data;

  TableData({required this.title, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Color(0xFF11c1f3),
          padding: EdgeInsets.all(10),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
        Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          border: TableBorder.all(),
          children: data.map((row) {
            return TableRow(
              children: row.map((cell) {
                return TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(cell),
                  ),
                );
              }).toList(),
            );
          }).toList(),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}