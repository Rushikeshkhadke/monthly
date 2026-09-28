class Cycle {
  final int? id;
  final DateTime startDate;
  final DateTime? endDate;
  final int? cycleLength;
  final int? periodLength;
  final bool isPredicted;
  final String? notes;

  const Cycle({
    this.id,
    required this.startDate,
    this.endDate,
    this.cycleLength,
    this.periodLength,
    this.isPredicted = false,
    this.notes,
  });

  Cycle copyWith({
    int? id,
    DateTime? startDate,
    DateTime? endDate,
    int? cycleLength,
    int? periodLength,
    bool? isPredicted,
    String? notes,
  }) {
    return Cycle(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      cycleLength: cycleLength ?? this.cycleLength,
      periodLength: periodLength ?? this.periodLength,
      isPredicted: isPredicted ?? this.isPredicted,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'start_date': startDate.toIso8601String().split('T').first,
      'end_date': endDate?.toIso8601String().split('T').first,
      'cycle_length': cycleLength,
      'period_length': periodLength,
      'is_predicted': isPredicted ? 1 : 0,
      'notes': notes,
    };
  }

  factory Cycle.fromMap(Map<String, dynamic> map) {
    return Cycle(
      id: map['id'] as int?,
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date'] as String) : null,
      cycleLength: map['cycle_length'] as int?,
      periodLength: map['period_length'] as int?,
      isPredicted: (map['is_predicted'] as int? ?? 0) == 1,
      notes: map['notes'] as String?,
    );
  }
}
