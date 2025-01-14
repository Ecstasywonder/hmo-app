import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'This Month';
  
  // Sample data - replace with real data
  final Map<String, dynamic> _statistics = {
    'totalClaims': 156,
    'pendingClaims': 45,
    'approvedClaims': 98,
    'rejectedClaims': 13,
    'totalAmount': '₦15,750,000',
    'averageProcessingTime': '3.2 days',
  };

  final List<Map<String, dynamic>> _monthlyData = [
    {'month': 'Jan', 'claims': 42, 'amount': 3200000},
    {'month': 'Feb', 'claims': 38, 'amount': 2900000},
    {'month': 'Mar', 'claims': 45, 'amount': 3500000},
    {'month': 'Apr', 'claims': 31, 'amount': 2400000},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics',
            style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onSelected: (value) {
              // Handle export options
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export_pdf',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf),
                    SizedBox(width: 8),
                    Text('Export as PDF'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export_excel',
                child: Row(
                  children: [
                    Icon(Icons.table_chart),
                    SizedBox(width: 8),
                    Text('Export as Excel'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Selection
            Row(
              children: [
                const Text(
                  'Period:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedPeriod,
                  items: ['This Week', 'This Month', 'Last 3 Months', 'This Year']
                      .map((period) => DropdownMenuItem(
                            value: period,
                            child: Text(period),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedPeriod = value);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Statistics Cards
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(
                  'Total Claims',
                  _statistics['totalClaims'].toString(),
                  Colors.blue,
                  Icons.assignment,
                ),
                _buildStatCard(
                  'Pending Claims',
                  _statistics['pendingClaims'].toString(),
                  Colors.orange,
                  Icons.pending_actions,
                ),
                _buildStatCard(
                  'Approved Claims',
                  _statistics['approvedClaims'].toString(),
                  Colors.green,
                  Icons.check_circle,
                ),
                _buildStatCard(
                  'Rejected Claims',
                  _statistics['rejectedClaims'].toString(),
                  Colors.red,
                  Icons.cancel,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Claims Distribution Chart
            _buildSectionTitle('Claims Distribution'),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: _statistics['pendingClaims'].toDouble(),
                      title: 'Pending',
                      color: Colors.orange,
                      radius: 50,
                    ),
                    PieChartSectionData(
                      value: _statistics['approvedClaims'].toDouble(),
                      title: 'Approved',
                      color: Colors.green,
                      radius: 50,
                    ),
                    PieChartSectionData(
                      value: _statistics['rejectedClaims'].toDouble(),
                      title: 'Rejected',
                      color: Colors.red,
                      radius: 50,
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Monthly Trends
            _buildSectionTitle('Monthly Trends'),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < _monthlyData.length) {
                            return Text(_monthlyData[value.toInt()]['month']);
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        _monthlyData.length,
                        (index) => FlSpot(
                          index.toDouble(),
                          _monthlyData[index]['claims'].toDouble(),
                        ),
                      ),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, Color color, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
} 