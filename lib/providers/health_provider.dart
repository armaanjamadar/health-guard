import 'package:flutter/foundation.dart';
import '../models/health_history.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HealthProvider extends ChangeNotifier {
  HealthProvider() {
    loadHealthHistory();
  }

  static const List<String> healthTips = [
    'Drink enough water throughout the day to stay hydrated.',
    'Aim for 7–9 hours of quality sleep every night.',
    'Include fruits and vegetables in your daily meals.',
    'Take short breaks from sitting and move around regularly.',
    'Regular physical activity can help improve your overall health.',
    'Limit excessive sugary and highly processed foods.',
    'Maintain good hand hygiene to help prevent infections.',
    'Spend some time outdoors and stay physically active.',
    'Make time for relaxation and activities that help you unwind.',
    'Maintain a consistent daily routine to support healthy habits.',
  ];

  static const double _waterIdealMin = 3, _waterIdealMax = 5;
  static const double _waterHardMin = 0, _waterHardMax = 8;

  static const double _sleepIdealMin = 7, _sleepIdealMax = 9;
  static const double _sleepHardMin = 3, _sleepHardMax = 14;

  static const double _exerciseIdealMin = 120, _exerciseIdealMax = 240;
  static const double _exerciseHardMin = 0, _exerciseHardMax = 480;

  static const double _maxPlausibleWater = 10;
  static const double _maxPlausibleSleep = 16;
  static const int _maxPlausibleExercise = 12 * 60;

  static const double _penaltyThreshold = 0.5;
  static const double _maxPenalty = 0.5;

  double waterIntake = 0;
  double sleepHours = 0;
  String diet = '';
  int exerciseHours = 0;
  int exerciseMinutes = 0;

  double bmi = 0;
  String bmiCategory = '';
  String bmiRecommendation = '';

  int healthScore = 0;
  int waterScore = 0;
  int sleepScore = 0;
  int dietScore = 0;
  int exerciseScore = 0;

  double penaltyMultiplier = 1.0;

  String recommendation = '';

  List<HealthHistory> healthHistory = [];

  void updateWater(double value) {
    waterIntake = value;
    notifyListeners();
  }

  void updateSleep(double value) {
    sleepHours = value;
    notifyListeners();
  }

  void updateDiet(String value) {
    diet = value;
    notifyListeners();
  }

  void updateExercise(int hours, int minutes) {
    exerciseHours = hours;
    exerciseMinutes = minutes;
    notifyListeners();
  }

  int get _totalExerciseMinutes => (exerciseHours * 60) + exerciseMinutes;

  List<String> get invalidInputs {
    final issues = <String>[];

    if (waterIntake.isNaN || waterIntake < 0 || waterIntake > _maxPlausibleWater) {
      issues.add('water');
    }
    if (sleepHours.isNaN || sleepHours < 0 || sleepHours > _maxPlausibleSleep) {
      issues.add('sleep');
    }
    if (_totalExerciseMinutes < 0 ||
        _totalExerciseMinutes > _maxPlausibleExercise) {
      issues.add('exercise');
    }

    if (issues.isEmpty && sleepHours + (_totalExerciseMinutes / 60) > 24) {
      issues.add('sleep and exercise combined');
    }

    return issues;
  }

  double _rangeRatio(
      double value, {
        required double hardMin,
        required double idealMin,
        required double idealMax,
        required double hardMax,
      }) {
    if (value.isNaN) return 0;
    if (value >= idealMin && value <= idealMax) return 1.0;
    if (value <= hardMin || value >= hardMax) return 0.0;

    if (value < idealMin) {
      return (value - hardMin) / (idealMin - hardMin);
    }
    return (hardMax - value) / (hardMax - idealMax);
  }

  int _calculateDietScore() {
    switch (diet) {
      case 'Very Poor':
        return 5;
      case 'Poor':
        return 10;
      case 'Average':
        return 15;
      case 'Good':
        return 20;
      case 'Excellent':
        return 25;
      default:
        return 0;
    }
  }

  double _calculatePenaltyMultiplier(List<double> ratios) {
    final weakest = ratios.reduce((a, b) => a < b ? a : b);

    if (weakest >= _penaltyThreshold) return 1.0;

    return (1 - _maxPenalty) + _maxPenalty * (weakest / _penaltyThreshold);
  }

  void calculateScore() {
    final waterRatio = _rangeRatio(
      waterIntake,
      hardMin: _waterHardMin,
      idealMin: _waterIdealMin,
      idealMax: _waterIdealMax,
      hardMax: _waterHardMax,
    );
    final sleepRatio = _rangeRatio(
      sleepHours,
      hardMin: _sleepHardMin,
      idealMin: _sleepIdealMin,
      idealMax: _sleepIdealMax,
      hardMax: _sleepHardMax,
    );
    final exerciseRatio = _rangeRatio(
      _totalExerciseMinutes.toDouble(),
      hardMin: _exerciseHardMin,
      idealMin: _exerciseIdealMin,
      idealMax: _exerciseIdealMax,
      hardMax: _exerciseHardMax,
    );

    waterScore = (waterRatio * 25).round();
    sleepScore = (sleepRatio * 25).round();
    exerciseScore = (exerciseRatio * 25).round();
    dietScore = _calculateDietScore();
    final dietRatio = dietScore / 25;

    final invalid = invalidInputs;
    if (invalid.isNotEmpty) {
      penaltyMultiplier = 0;
      healthScore = 0;
      recommendation =
      'Some of your entries look unrealistic (${invalid.join(', ')}). '
          'Please check them and try again.';
      notifyListeners();
      return;
    }

    final rawScore = waterScore + sleepScore + dietScore + exerciseScore;

    penaltyMultiplier = _calculatePenaltyMultiplier([waterRatio, sleepRatio, exerciseRatio, dietRatio]);

    healthScore = (rawScore * penaltyMultiplier).round();

    recommendation = _generateRecommendation();

    notifyListeners();
  }

  void calculateBmi(double heightCm, double weightKg) {
    if (heightCm <= 0 || weightKg <= 0) {
      bmi = 0;
      bmiCategory = '';
      notifyListeners();
      return;
    }

    final heightM = heightCm / 100;

    bmi = weightKg / (heightM * heightM);

    if (bmi < 16) {
      bmiCategory = 'Malnourished';
    } else if (bmi < 18.5) {
      bmiCategory = 'Underweight';
    } else if (bmi < 25) {
      bmiCategory = 'Normal weight';
    } else if (bmi < 30) {
      bmiCategory = 'Overweight';
    } else {
      bmiCategory = 'Obese';
    }

    notifyListeners();
  }

  Future<void> saveHealthHistory() async {
    if (invalidInputs.isNotEmpty) return;

    final prefs = await SharedPreferences.getInstance();

    final history = HealthHistory(
      date: DateTime.now().toIso8601String(),
      healthScore: healthScore,
      waterScore: waterScore,
      sleepScore: sleepScore,
      dietScore: dietScore,
      exerciseScore: exerciseScore,
    );

    healthHistory.add(history);

    final historyJson = healthHistory.map((item) => item.toJson()).toList();

    await prefs.setString('health_history', jsonEncode(historyJson));

    notifyListeners();
  }

  Future<void> loadHealthHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final historyString = prefs.getString('health_history');

      if (historyString == null) {
        return;
      }

      final List<dynamic> historyJson = jsonDecode(historyString);

      healthHistory = historyJson.map((item) => HealthHistory.fromJson(item)).toList();

      notifyListeners();
    } catch (e) {
      // Catch error and prevent crash
    }
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('health_history');

    healthHistory = [];

    notifyListeners();
  }

  String _generateRecommendation() {
    final areas = <String, int>{
      'water': waterScore,
      'sleep': sleepScore,
      'diet': dietScore,
      'exercise': exerciseScore,
    }.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    final recommendations = areas
        .where((entry) => _needsRecommendation(entry.key, entry.value))
        .map((entry) => _recommendationFor(entry.key))
        .toList();

    if (recommendations.isEmpty) {
      return 'Your health habits are looking great overall. Keep maintaining the routine that is working for you.';
    }

    return _combineRecommendations(recommendations);
  }

  bool _needsRecommendation(String category, int score) {
    return category == 'diet' ? score <= 15 : score < 21;
  }

  String _recommendationFor(String category) {
    switch (category) {
      case 'water':
        if (waterIntake < 2) {
          return 'Your water is quite low today, so increasing it gradually throughout the day can help you stay better hydrated.';
        }

        if (waterIntake < 3) {
          return 'You could use a little more water today to support good hydration, so try drinking regularly rather than waiting until you feel thirsty.';
        }

        if (waterIntake > 5 && waterIntake <= 6) {
          return 'You have already had more water than required, so there is no need to keep increasing your intake.';
        }

        return 'Your water is quite high today, so focus on drinking according to your body’s needs rather than deliberately adding more.';

      case 'sleep':
        if (sleepHours < 6) {
          return 'You are getting quite a bit less sleep than you need for proper rest, so giving your body and mind more time to recover should be a priority.';
        }

        if (sleepHours < 7) {
          return 'You could use a little more sleep to give your body and mind enough time to recover, so try allowing yourself some extra rest.';
        }

        if (sleepHours > 9 && sleepHours <= 10) {
          return 'You are sleeping a little longer than your required sleep, so keeping a consistent sleep schedule may help keep your routine balanced.';
        }

        return 'You are sleeping considerably longer than the required sleep, so paying attention to your sleep schedule and overall routine may be helpful.';

      case 'diet':
        if (diet == 'Average') {
          return 'Your diet could be more balanced and nutritious, so try making your meals a little more varied and nutrient-rich.';
        }

        if (diet == 'Poor') {
          return 'Your current food choices could provide better overall nutrition, so focusing on more balanced meals would be a worthwhile improvement.';
        }

        return 'Your diet needs more attention, so gradually moving towards more balanced and nutritious meals would be a good place to start.';

      case 'exercise':
        final minutes = _totalExerciseMinutes;

        if (minutes < 60) {
          return 'You have had very little physical activity today, so adding some more movement to your routine would help you stay more active.';
        }

        if (minutes < 120) {
          return 'You have been somewhat active today, but adding a little more physical activity would help strengthen your daily routine.';
        }

        if (minutes <= 300) {
          return 'You have been quite active today, so give your body enough time to recover before adding more activity.';
        }

        return 'You have done a lot of physical activity today, so make sure you allow enough time for rest and recovery rather than continuing to push yourself.';
    }

    return 'A few changes to your daily habits could help improve your overall health routine.';
  }

  String _combineRecommendations(List<String> recommendations) {
    if (recommendations.length == 1) {
      return recommendations.first;
    }

    if (recommendations.length == 2) {
      return '${recommendations[0]} ${recommendations[1]}';
    }

    final first = recommendations.take(recommendations.length - 1).join(' ');
    final last = recommendations.last;

    return '$first Finally, $last';
  }
}