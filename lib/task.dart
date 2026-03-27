class Task {
  String task;
  bool done;
  String id;
  Task({required this.task, required this.done, required this.id});
  factory Task.fromJson(Map<String, dynamic> json) =>
      Task(task: json["task"], done: json["done"], id: json["id"]);

  Map<String, dynamic> toJson() => {"task": task, "done": done, "id": id};
}
