class Group {
  const Group({required this.id, required this.name, required this.createdBy});

  final int id;
  final String name;
  final int createdBy;

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] as int,
      name: json['name'] as String,
      createdBy: json['created_by'] as int,
    );
  }
}
