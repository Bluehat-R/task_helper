class LogEntry {
  final int? id;
  final String type;       // "pc_start" など
  final DateTime timestamp;

  LogEntry({
    this.id,
    required this.type,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory LogEntry.fromMap(Map<String, dynamic> map) {
    return LogEntry(
      id: map['id'] as int?,
      type: map['type'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}
