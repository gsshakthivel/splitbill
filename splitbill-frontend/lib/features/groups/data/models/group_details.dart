import 'member.dart';

class GroupDetails {
  const GroupDetails({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.members,
  });

  final int id;
  final String name;
  final int createdBy;
  final List<Member> members;

  factory GroupDetails.fromJson(Map<String, dynamic> json) {
    return GroupDetails(
      id: json['id'] as int,
      name: json['name'] as String,
      createdBy: json['createdBy'] as int,
      members: (json['members'] as List<dynamic>)
          .map((member) => Member.fromJson(member as Map<String, dynamic>))
          .toList(),
    );
  }
}
