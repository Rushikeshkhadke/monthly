class TrackerEntry {
  final int? id;
  final int? dailyLogId;
  final String trackerType; // 'medication', 'supplement', 'workout', 'custom'
  final String name; // e.g. 'Iron supplement', 'Vitamin D', 'Pilates'
  final bool isCompleted;
  final String? value; // dosage or duration or notes

  const TrackerEntry({
    this.id,
    this.dailyLogId,
    required this.trackerType,
    required this.name,
    this.isCompleted = true,
    this.value,
  });

  TrackerEntry copyWith({
    int? id,
    int? dailyLogId,
    String? trackerType,
    String? name,
    bool? isCompleted,
    String? value,
  }) {
    return TrackerEntry(
      id: id ?? this.id,
      dailyLogId: dailyLogId ?? this.dailyLogId,
      trackerType: trackerType ?? this.trackerType,
      name: name ?? this.name,
      isCompleted: isCompleted ?? this.isCompleted,
      value: value ?? this.value,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'daily_log_id': dailyLogId,
      'tracker_type': trackerType,
      'name': name,
      'is_completed': isCompleted ? 1 : 0,
      'value': value,
    };
  }

  factory TrackerEntry.fromMap(Map<String, dynamic> map) {
    return TrackerEntry(
      id: map['id'] as int?,
      dailyLogId: map['daily_log_id'] as int?,
      trackerType: map['tracker_type'] as String,
      name: map['name'] as String,
      isCompleted: (map['is_completed'] as int? ?? 1) == 1,
      value: map['value'] as String?,
    );
  }
}
