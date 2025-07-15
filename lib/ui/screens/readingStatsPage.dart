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


  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  // Eğer hiç veri yoksa bilgilendirici metin göster
  if (categoryStats.isEmpty) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategori İstatistikleri'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'Henüz istatistik gösterilecek kitap verisi yok.',
          style: TextStyle(fontSize: screenWidth * 0.04),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  final maxY = (values.reduce((a, b) => a > b ? a : b) + 1).toDouble();

  return Scaffold(
    appBar: AppBar(
      title: const Text('Kategori İstatistikleri'),
      centerTitle: true,
    ),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 80, right: 50, left: 50, bottom: 50),
        child: BarChart(
          BarChartData(
            maxY: maxY,
            alignment: BarChartAlignment.spaceAround,
            barGroups: List.generate(categories.length, (index) {
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: values[index].toDouble(),
                    color: AppPallete.gradient1,
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
                  reservedSize: 40,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    final intValue = value.toInt();
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        intValue.toString(),
                        style: const TextStyle(fontSize: 15),
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
                    if (index < categories.length) {
                      return RotatedBox(
                        quarterTurns: 3,
                        child: Text(
                          categories[index],
                          style: const TextStyle(fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
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
