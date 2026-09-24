import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_provider.dart';

class BmiResultScreen extends StatelessWidget {
  const BmiResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final healthProvider = context.watch<HealthProvider>();

    String recommendation;

    switch (healthProvider.bmiCategory) {
      case 'Malnourished':
        recommendation =
        'Your BMI is significantly below the usual healthy range and may indicate undernutrition. It is important to take this seriously and focus on adequate, balanced nutrition. Consider speaking with a healthcare professional or qualified nutritionist for proper assessment and guidance.';
        break;

      case 'Underweight':
        recommendation =
        'Your BMI is below the usual healthy range. Focus on regular, balanced and nutritious meals to support healthy weight gain. If you have difficulty gaining weight or concerns about your weight, consider speaking with a healthcare professional.';
        break;

      case 'Normal weight':
        recommendation =
        'Congratulations! 🎉 Your BMI is within the usual healthy range. This is a great sign that you are maintaining a healthy weight. Keep up your balanced diet, regular physical activity and healthy lifestyle habits.';
        break;

      case 'Overweight':
        recommendation =
        'Your BMI is slightly above the usual healthy range. There is no need to panic, but it may be a good time to pay a little more attention to your eating habits and physical activity. Small, consistent lifestyle changes can make a positive difference over time.';
        break;

      case 'Obese':
        recommendation =
        'Your BMI is considerably above the usual healthy range. This can be associated with increased health risks, so it is important to take it seriously. Focus on gradual, sustainable improvements in nutrition and physical activity, and consider speaking with a healthcare professional for personalized guidance.';
        break;

      default:
        recommendation = 'No BMI result available.';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'BMI Result',
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
            // BMI Score Card
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
                    'Your BMI',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    healthProvider.bmi.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      healthProvider.bmiCategory,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Recommendation Card
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
                        'Recommendation',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Text(
                    recommendation,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Disclaimer
            Text(
              'BMI is a general screening measure and does not provide a complete assessment of individual health.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}