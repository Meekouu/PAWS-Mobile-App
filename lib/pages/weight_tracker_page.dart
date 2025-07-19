import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class WeightTrackerPage extends StatefulWidget {
  @override
  _WeightTrackerPageState createState() => _WeightTrackerPageState();
}

class _WeightTrackerPageState extends State<WeightTrackerPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<FlSpot> weightData = [
    FlSpot(0, 62),
    FlSpot(1, 59),
    FlSpot(2, 58),
    FlSpot(3, 59),
    FlSpot(4, 58),
    FlSpot(5, 57.5),
    FlSpot(6, 57),
    FlSpot(7, 56),
    FlSpot(8, 57),
  ];

  double get currentWeight => weightData.last.y;
  double get weightChange => weightData.first.y - currentWeight;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addWeightEntry() {
    // Placeholder for backend or form logic
    setState(() {
      weightData.add(FlSpot(weightData.length.toDouble(), currentWeight - 0.5));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weight Tracker'),
        backgroundColor: Color(0xFFA8D5BA),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.show_chart), text: 'STATISTICS'),
            Tab(icon: Icon(Icons.history), text: 'HISTORY'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStatisticsTab(),
          _buildHistoryTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFA8D5BA),
        onPressed: _addWeightEntry,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        const labels = ['17 Oct', '24 Oct', '31 Oct', '7 Nov', '14 Nov'];
                        int index = value.toInt();
                        return Text(index < labels.length ? labels[index] : '');
                      },
                      interval: 1,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, interval: 1),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: true),
                minX: 0,
                maxX: 8,
                minY: 54,
                maxY: 64,
                lineBarsData: [
                  LineChartBarData(
                    spots: weightData,
                    isCurved: true,
                    barWidth: 3,
                    color: Colors.blue,
                    dotData: FlDotData(show: false),
                  )
                ],
              ),
            ),
          ),
        ),
        _buildWeightCard('${currentWeight.toStringAsFixed(1)} kg', 'Current weight'),
        _buildWeightCard('${weightChange > 0 ? '-' : ''}${weightChange.toStringAsFixed(1)} kg', 'Progress done'),
      ],
    );
  }

  Widget _buildWeightCard(String value, String label) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: Container(
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    return ListView.builder(
      itemCount: weightData.length,
      itemBuilder: (context, index) {
        final entry = weightData[index];
        return ListTile(
          leading: const Icon(Icons.monitor_weight),
          title: Text('${entry.y.toStringAsFixed(1)} kg'),
          subtitle: Text('Day ${entry.x.toInt()}'),
        );
      },
    );
  }
}
