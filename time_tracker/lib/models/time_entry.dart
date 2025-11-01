import 'project.dart';
import 'task.dart';

class TimeEntry {
  final String id;
  final Project project;
  final Task task;
  final DateTime date;
  final Duration totalTime;
  final String notes;

  TimeEntry({
    required this.id,
    required this.project,
    required this.task,
    required this.date,
    required this.totalTime,
    this.notes = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project': project.toJson(),
      'task': task.toJson(),
      'date': date.toIso8601String(),
      'totalTimeInSeconds': totalTime.inSeconds,
      'notes': notes,
    };
  }

  factory TimeEntry.fromJson(Map<String, dynamic> json) {
    return TimeEntry(
      id: json['id'] as String,
      project: Project.fromJson(json['project'] as Map<String, dynamic>),
      task: Task.fromJson(json['task'] as Map<String, dynamic>),
      date: DateTime.parse(json['date'] as String),
      totalTime: Duration(seconds: json['totalTimeInSeconds'] as int),
      notes: json['notes'] as String,
    );
  }
}
