class HealthHistory {
  final String date;
  final int healthScore;
  final int waterScore;
  final int sleepScore;
  final int dietScore;
  final int exerciseScore;

  HealthHistory({
    required this.date,
    required this.healthScore,
    required this.waterScore,
    required this.sleepScore,
    required this.dietScore,
    required this.exerciseScore,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'healthScore': healthScore,
      'waterScore': waterScore,
      'sleepScore': sleepScore,
      'dietScore': dietScore,
      'exerciseScore': exerciseScore,
    };
  }

  factory HealthHistory.fromJson(Map<String, dynamic> json) {
    return HealthHistory(
      date: json['date'],
      healthScore: json['healthScore'],
      waterScore: json['waterScore'],
      sleepScore: json['sleepScore'],
      dietScore: json['dietScore'],
      exerciseScore: json['exerciseScore'],
    );
  }
}