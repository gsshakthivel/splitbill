class CreateGroupRequest {
  const CreateGroupRequest({required this.name});

  final String name;

  Map<String, dynamic> toJson() {
    return {'name': name};
  }
}
