class TaskModel {
  String title;
  String description;
  String date;
  String status;
  String priority;

  TaskModel({
    required this.title,
    required this.description,
    required this.date,
    required this.status,
    required this.priority,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      title: json['title'],
      description: json['description'],
      date: json['date'],
      status: json['status'],
      priority: json['priority'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'date': date,
      'status': status,
      'priority': priority,
    };
  }
}
