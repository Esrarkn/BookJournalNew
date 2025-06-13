import 'package:book_journal/core/theme.dart/appPalette.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CategoryStatisticsPage extends StatelessWidget {
  final Map<String, int> categoryStats;

  const CategoryStatisticsPage({Key? key, required this.categoryStats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categories = categoryStats.keys.toList();
    final values = categoryStats.values.toList();
    final maxY = (values.isNotEmpty) 
        ? (values.reduce((a, b) => a > b ? a : b) + 1)
        : 1;

    return Scaffold(
      appBar: AppBar(
        title: Text('Kategori İstatistikleri'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top:80,right: 50,left: 50,bottom: 50),
          child: BarChart(
            BarChartData(
              maxY: maxY.toDouble(),
              alignment: BarChartAlignment.spaceAround,
              barGroups: List.generate(categories.length, (index) {
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: values[index].toDouble(),
                      color: AppPallete.gradient3,
                      width: 25,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ],
                );
              }),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,  // Sol başlık için ayırdığımız alanı azalttık
                    interval: 1,  // Y eksenindeki sayılar arasındaki mesafeyi azaltıyoruz
                    getTitlesWidget: (value, meta) {
                      final intValue = value.toInt();
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          intValue.toString(),
                          style: TextStyle(fontSize: 15),
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          index < categories.length ? categories[index] : '',
                          style: TextStyle(fontSize: 15),
                        ),
                      );
                    },
                    reservedSize: 80,
                  ),
                ),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
      ),
    );
  }
}
