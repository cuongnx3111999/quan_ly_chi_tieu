import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:money_grower/helper/format_helper.dart';
import 'package:random_color/random_color.dart';

class DonutPieChart extends StatelessWidget {
  final List transactionList;

  DonutPieChart(this.transactionList);

  final formatter = FormatHelper();
  final randomColor = RandomColor();

  @override
  Widget build(BuildContext context) {
    if (transactionList.isEmpty) {
      return Center(child: Text('Không có dữ liệu'));
    }

    final sections = transactionList.asMap().entries.map((entry) {
      final transaction = entry.value;
      final name = transaction.name;
      final price = transaction.price as int;
      final absPrice = price.abs().toDouble();

      final color = _generateColor(price);

      return PieChartSectionData(
        color: color,
        value: absPrice,
        title: '${name}\n${formatter.formatMoney(absPrice.toInt(), 'đ')}',
        radius: 80,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Container(
      height: 250,
      child: PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 60,
          sectionsSpace: 2,
          borderData: FlBorderData(show: false),
          pieTouchData: PieTouchData(enabled: false),
        ),
      ),
    );
  }

  Color _generateColor(int price) {
    if (price < 0) {
      return randomColor.randomColor(
        colorHue: ColorHue.multiple(colorHues: [ColorHue.pink, ColorHue.red]),
        colorSaturation: ColorSaturation.mediumSaturation,
        colorBrightness: ColorBrightness.dark,
      );
    } else {
      return randomColor.randomColor(
        colorHue: ColorHue.green,
        colorSaturation: ColorSaturation.mediumSaturation,
        colorBrightness: ColorBrightness.dark,
      );
    }
  }
}
