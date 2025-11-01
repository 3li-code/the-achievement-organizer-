class Task {
  final String id;
  String name;

  Task({required this.id, required this.name});

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(id: json['id'] as String, name: json['name'] as String);
  }
}
