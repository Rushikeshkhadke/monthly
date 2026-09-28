enum FlowIntensity {
  none,
  light,
  medium,
  heavy;

  static FlowIntensity fromString(String? val) {
    return FlowIntensity.values.firstWhere(
      (e) => e.name == val,
      orElse: () => FlowIntensity.none,
    );
  }
}

enum MoodType {
  happy,
  calm,
  irritable,
  sad,
  anxious;

  static MoodType? fromString(String? val) {
    if (val == null) return null;
    return MoodType.values.firstWhere(
      (e) => e.name == val,
      orElse: () => MoodType.calm,
    );
  }
}

class DailyLog {
  final int? id;
  final DateTime logDate;
  final FlowIntensity flow;
  final MoodType? mood;
  final int painLevel; // 0 to 5
  final int energyLevel; // 0 to 5
  final List<String> symptoms;
  final bool medication;
  final bool supplements;
  final bool workout;
  final String? notes;

  const DailyLog({
    this.id,
    required this.logDate,
    this.flow = FlowIntensity.none,
    this.mood,
    this.painLevel = 0,
    this.energyLevel = 3,
    this.symptoms = const [],
    this.medication = false,
    this.supplements = false,
    this.workout = false,
    this.notes,
  });

  DailyLog copyWith({
    int? id,
    DateTime? logDate,
    FlowIntensity? flow,
    MoodType? mood,
    int? painLevel,
    int? energyLevel,
    List<String>? symptoms,
    bool? medication,
    bool? supplements,
    bool? workout,
    String? notes,
  }) {
    return DailyLog(
      id: id ?? this.id,
      logDate: logDate ?? this.logDate,
      flow: flow ?? this.flow,
      mood: mood ?? this.mood,
      painLevel: painLevel ?? this.painLevel,
      energyLevel: energyLevel ?? this.energyLevel,
      symptoms: symptoms ?? this.symptoms,
      medication: medication ?? this.medication,
      supplements: supplements ?? this.supplements,
      workout: workout ?? this.workout,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'log_date': logDate.toIso8601String().split('T').first,
      'flow_intensity': flow.name,
      'mood': mood?.name,
      'pain_level': painLevel,
      'energy_level': energyLevel,
      'medication': medication ? 1 : 0,
      'supplements': supplements ? 1 : 0,
      'workout': workout ? 1 : 0,
      'notes': notes,
    };
  }

  factory DailyLog.fromMap(Map<String, dynamic> map, {List<String> symptoms = const []}) {
    return DailyLog(
      id: map['id'] as int?,
      logDate: DateTime.parse(map['log_date'] as String),
      flow: FlowIntensity.fromString(map['flow_intensity'] as String?),
      mood: MoodType.fromString(map['mood'] as String?),
      painLevel: map['pain_level'] as int? ?? 0,
      energyLevel: map['energy_level'] as int? ?? 3,
      symptoms: symptoms,
      medication: (map['medication'] as int? ?? 0) == 1,
      supplements: (map['supplements'] as int? ?? 0) == 1,
      workout: (map['workout'] as int? ?? 0) == 1,
      notes: map['notes'] as String?,
    );
  }
}
