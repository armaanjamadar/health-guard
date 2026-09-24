import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  String _formatDate(String date) {
    final parsedDate = DateTime.parse(date);

    int hour = parsedDate.hour;

    final period = hour >= 12 ? 'PM' : 'AM';

    hour = hour % 12;

    if (hour == 0) {
      hour = 12;
    }

    return '${parsedDate.day} '
        '${_monthName(parsedDate.month)} '
        '${parsedDate.year} • '
        '$hour:'
        '${parsedDate.minute.toString().padLeft(2, '0')} '
        '$period';
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return months[month - 1];
  }

  Future<void> _confirmClearHistory(BuildContext context) async {
    final healthProvider = context.read<HealthProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 28),
        ),
        title: const Text(
          'Clear History?',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'This will permanently delete all your saved health history.\nThis action cannot be undone.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await healthProvider.clearHistory();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: const Text('Health history cleared'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final healthProvider = context.watch<HealthProvider>();
    final history = healthProvider.healthHistory;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Health History',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Clear history',
              onPressed: () => _confirmClearHistory(context),
            ),
        ],
      ),
      body: history.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_rounded,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No health history available yet.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        itemCount: history.length,
        itemBuilder: (context, index) {
          final originalIndex = history.length - 1 - index;
          final record = history[originalIndex];

          String progressStatus;
          if (originalIndex > 0) {
            final previousRecord = history[originalIndex - 1];
            if (record.healthScore > previousRecord.healthScore) {
              progressStatus = '↑ Improving';
            } else if (record.healthScore < previousRecord.healthScore) {
              progressStatus = '↓ Declining';
            } else {
              progressStatus = '→ Maintained';
            }
          } else {
            progressStatus = '---';
          }

          final Color statusColor =
          progressStatus.contains('Improving')
              ? Colors.green
              : progressStatus.contains('Declining')
              ? Colors.red
              : progressStatus.contains('Maintained')
              ? Colors.amber.shade700
              : Colors.black;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 17,
                      color: Color(0xFF1976D2),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _formatDate(record.date),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Health Score',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '${record.healthScore}/100',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D47A1),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          progressStatus,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Divider(height: 1),
                const SizedBox(height: 14),
                _buildMetricRow(
                  Icons.water_drop_rounded,
                  Colors.blue,
                  'Water',
                  record.waterScore,
                ),
                const SizedBox(height: 10),
                _buildMetricRow(
                  Icons.bedtime_rounded,
                  Colors.indigo,
                  'Sleep',
                  record.sleepScore,
                ),
                const SizedBox(height: 10),
                _buildMetricRow(
                  Icons.restaurant_rounded,
                  Colors.orange,
                  'Diet',
                  record.dietScore,
                ),
                const SizedBox(height: 10),
                _buildMetricRow(
                  Icons.fitness_center_rounded,
                  Colors.green,
                  'Exercise',
                  record.exerciseScore,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricRow(
      IconData icon,
      Color iconColor,
      String title,
      int score,
      ) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 19,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          '$score/25',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: iconColor,
          ),
        ),
      ],
    );
  }
}