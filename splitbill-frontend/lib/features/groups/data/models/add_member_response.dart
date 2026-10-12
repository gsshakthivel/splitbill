class AddMemberResponse {
  const AddMemberResponse({
    required this.groupId,
    required this.userId,
    required this.createdBy,
  });

  final int groupId;
  final int userId;
  final int createdBy;

  factory AddMemberResponse.fromJson(Map<String, dynamic> json) {
    return AddMemberResponse(
      groupId: json['groupId'] as int,
      userId: json['userId'] as int,
      createdBy: json['createdBy'] as int,
    );
  }
}
