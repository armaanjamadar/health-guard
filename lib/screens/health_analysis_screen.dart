import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_provider.dart';
import 'health_analysis_result_screen.dart';
import 'package:flutter/services.dart';

class HealthAnalysisScreen extends StatefulWidget {
  const HealthAnalysisScreen({super.key});

  @override
  State<HealthAnalysisScreen> createState() => _HealthAnalysisScreenState();
}

class _HealthAnalysisScreenState extends State<HealthAnalysisScreen> {
  final _waterController = TextEditingController();
  final _sleepController = TextEditingController();
  final _exerciseHoursController = TextEditingController();
  final _exerciseMinutesController = TextEditingController();
  String? _diet;
  bool _isSubmitting = false;

  static final _decimalFormatter = FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'));

  @override
  void dispose() {
    _waterController.dispose();
    _sleepController.dispose();
    _exerciseHoursController.dispose();
    _exerciseMinutesController.dispose();
    super.dispose();
  }

  double? _parseDecimal(String text) {
    final value = double.tryParse(text.trim().replaceAll(',', '.'));
    return (value != null && value.isFinite) ? value : null;
  }

  void _showSnackbar(String text) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          text,
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _onCalculatePressed() async {
    final provider = context.read<HealthProvider>();

    final water = _parseDecimal(_waterController.text);
    if (water == null || water <= 0) {
      _showSnackbar('Please enter a valid water.');
      return;
    }

    final sleep = _parseDecimal(_sleepController.text);
    if (sleep == null || sleep <= 0) {
      _showSnackbar('Please enter valid sleep hours.');
      return;
    }

    if (_diet == null) {
      _showSnackbar('Please select your diet quality.');
      return;
    }

    final hoursText = _exerciseHoursController.text.trim();
    final minutesText = _exerciseMinutesController.text.trim();
    final hours = hoursText.isEmpty ? 0 : int.tryParse(hoursText);
    final minutes = minutesText.isEmpty ? 0 : int.tryParse(minutesText);

    if (hours == null || minutes == null || minutes > 59) {
      _showSnackbar('Please enter valid exercise time (minutes 0-59).');
      return;
    }

    provider.updateWater(water);
    provider.updateSleep(sleep);
    provider.updateDiet(_diet!);
    provider.updateExercise(hours, minutes);

    final invalid = provider.invalidInputs;
    if (invalid.isNotEmpty) {
      _showSnackbar('These values look unrealistic: ${invalid.join(', ')}.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      provider.calculateScore();
      await provider.saveHealthHistory();
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HealthAnalysisResultScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Health Analysis',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Check Your Health',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Enter your daily habits to calculate your health score.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 26),
            // Water
            _buildSectionCard(
              icon: Icons.water_drop_rounded,
              iconColor: Colors.blue,
              title: 'Water',
              child: TextField(
                controller: _waterController,
                inputFormatters: [_decimalFormatter],
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: _inputDecoration(
                  label: 'Water (Litres)',
                  hint: 'e.g. 2.5',
                  icon: Icons.water_drop_outlined,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Sleep
            _buildSectionCard(
              icon: Icons.bedtime_rounded,
              iconColor: Colors.indigo,
              title: 'Sleep',
              child: TextField(
                controller: _sleepController,
                inputFormatters: [_decimalFormatter],
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                decoration: _inputDecoration(
                  label: 'Sleep (Hours)',
                  hint: 'e.g. 7.5',
                  icon: Icons.bedtime_outlined,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Diet
            _buildSectionCard(
              icon: Icons.restaurant_rounded,
              iconColor: Colors.orange,
              title: 'Diet',
              child: DropdownButtonFormField<String>(
                decoration: _inputDecoration(
                  label: 'Diet Quality',
                  icon: Icons.restaurant_outlined,
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Very Poor',
                    child: Text('Very Poor'),
                  ),
                  DropdownMenuItem(
                    value: 'Poor',
                    child: Text('Poor'),
                  ),
                  DropdownMenuItem(
                    value: 'Average',
                    child: Text('Average'),
                  ),
                  DropdownMenuItem(
                    value: 'Good',
                    child: Text('Good'),
                  ),
                  DropdownMenuItem(
                    value: 'Excellent',
                    child: Text('Excellent'),
                  ),
                ],
                onChanged: (value) => _diet = value,
              ),
            ),
            const SizedBox(height: 16),
            // Exercise
            _buildSectionCard(
              icon: Icons.fitness_center_rounded,
              iconColor: Colors.green,
              title: 'Exercise',
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _exerciseHoursController,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration(
                        label: 'Hours',
                        icon: Icons.access_time_rounded,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _exerciseMinutesController,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration(
                        label: 'Minutes',
                        icon: Icons.timer_outlined,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            // Calculate button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _onCalculatePressed,
                icon: const Icon(Icons.analytics_rounded),
                label: const Text(
                  'Calculate Health Score',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D47A1),
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, 4),
            color: Colors.black12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    String? hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: const Color(0xFFF8FAFD),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF1976D2),
          width: 2,
        ),
      ),
    );
  }
}
