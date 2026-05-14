// lib/screens/reports_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:animate_do/animate_do.dart';
import '../providers/item_provider.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final itemProvider = Provider.of<ItemProvider>(context);

    /// ✅ Safe Firestore data handling
    final items = itemProvider.items;

    /// Total quantity
    final totalStock = items.fold<int>(
      0,
          (sum, item) => sum + item.quantity,
    );

    /// Low Stock Items (Firebase Compatible)
    final lowStockItems =
    items.where((item) => item.quantity <= 5).toList();

    final lowStockCount = lowStockItems.length;

    /// Category counts
    final Map<String, int> categoryCounts = {};
    for (var item in items) {
      categoryCounts[item.category] =
          (categoryCounts[item.category] ?? 0) + item.quantity;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reports',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔴 Low Stock Alert Banner
            if (lowStockCount > 0)
              FadeInDown(
                duration: const Duration(milliseconds: 700),
                child: Pulse(
                  infinite: true,
                  child: Card(
                    color: Colors.red.shade400,
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 80,
                      child: Center(
                        child: Text(
                          '⚠️ Low Stock Alert: $lowStockCount item(s) below threshold!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 24),

            /// 📊 Summary Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FadeInLeft(
                  duration: const Duration(milliseconds: 800),
                  child: _ReportCard(
                    title: 'Total Stock',
                    value: totalStock.toString(),
                    color: Colors.blue,
                  ),
                ),
                FadeInRight(
                  duration: const Duration(milliseconds: 900),
                  child: _ReportCard(
                    title: 'Low Stock',
                    value: lowStockCount.toString(),
                    color: Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            /// 📦 Bar Chart — Stock per Item
            FadeInUp(
              duration: const Duration(milliseconds: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stock per Item',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      height: 260,
                      child: items.isEmpty
                          ? Center(
                        child: Text(
                          "No data available",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      )
                          : BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: items
                              .map((e) => e.quantity)
                              .reduce((a, b) => a > b ? a : b)
                              .toDouble() +
                              5,
                          barGroups: items.map((item) {
                            final index = items.indexOf(item);
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: item.quantity.toDouble(),
                                  color: Colors.blueAccent,
                                  width: 18,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ],
                            );
                          }).toList(),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 5,
                                reservedSize: 28,
                                getTitlesWidget: (value, meta) =>
                                    Text(value.toInt().toString(),
                                        style: GoogleFonts.poppins(
                                            fontSize: 10)),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index >= 0 &&
                                      index < items.length) {
                                    return Transform.rotate(
                                      angle: -0.8,
                                      child: Text(
                                        items[index].name,
                                        style: GoogleFonts.poppins(
                                            fontSize: 10),
                                      ),
                                    );
                                  }
                                  return SizedBox.shrink();
                                },
                              ),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: FlGridData(show: true),
                          borderData: FlBorderData(show: false),
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              tooltipPadding: EdgeInsets.all(8),
                              tooltipMargin: 8,
                              getTooltipItem:
                                  (group, groupIndex, rod, rodIndex) {
                                final item = items[group.x.toInt()];
                                return BarTooltipItem(
                                  '${item.name}\nQty: ${item.quantity}',
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    backgroundColor:
                                    Color(0xDD000000),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            /// 🥧 Pie Chart — Stock by Category
            FadeInUp(
              duration: const Duration(milliseconds: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stock by Category',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      height: 250,
                      child: categoryCounts.isEmpty
                          ? Center(
                        child: Text(
                          'No category data available',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                          : PieChart(
                        PieChartData(
                          sections: categoryCounts.entries.map((entry) {
                            final color = Colors.primaries[
                            categoryCounts.keys
                                .toList()
                                .indexOf(entry.key) %
                                Colors.primaries.length];

                            return PieChartSectionData(
                              value: entry.value.toDouble(),
                              title: '${entry.key}\n(${entry.value})',
                              color: color,
                              radius: 70,
                              titleStyle: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }).toList(),
                          sectionsSpace: 4,
                          centerSpaceRadius: 40,
                          pieTouchData: PieTouchData(enabled: true),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🔷 Summary Card Widget
class _ReportCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _ReportCard({
    required this.title,
    required this.value,
    required this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.08),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: SizedBox(
        width: (MediaQuery.of(context).size.width - 48) / 2,
        height: 110,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
