import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_provider.dart';

class HealthAnalysisResultScreen extends StatelessWidget {
  const HealthAnalysisResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final healthProvider = context.watch<HealthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Health Results',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
        child: Column(
          children: [
            // Score Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 28,
                horizontal: 20,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF0D47A1),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Your Health Score',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${healthProvider.healthScore}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 58,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'out of 100',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Recommendation
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                  const Row(
                    children: [
                      Icon(
                        Icons.lightbulb_rounded,
                        color: Colors.orange,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Your Recommendation',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    healthProvider.recommendation,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Detailed Breakdown',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 14),

            _buildScoreCard(
              icon: Icons.water_drop_rounded,
              iconColor: Colors.blue,
              title: 'Water',
              score: healthProvider.waterScore,
            ),

            const SizedBox(height: 12),

            _buildScoreCard(
              icon: Icons.bedtime_rounded,
              iconColor: Colors.indigo,
              title: 'Sleep',
              score: healthProvider.sleepScore,
            ),

            const SizedBox(height: 12),

            _buildScoreCard(
              icon: Icons.restaurant_rounded,
              iconColor: Colors.orange,
              title: 'Diet',
              score: healthProvider.dietScore,
            ),

            const SizedBox(height: 12),

            _buildScoreCard(
              icon: Icons.fitness_center_rounded,
              iconColor: Colors.green,
              title: 'Exercise',
              score: healthProvider.exerciseScore,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required int score,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 26,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Text(
            '$score/25',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }
}