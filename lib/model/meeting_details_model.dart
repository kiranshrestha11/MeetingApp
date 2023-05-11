// ignore_for_file: public_member_api_docs, sort_constructors_first
class MeetingDetailsModel {
  String id;
  String? hostId;
  String? hostName;
  MeetingDetailsModel({
    required this.id,
    this.hostId,
    this.hostName,
  });

  factory MeetingDetailsModel.fromJson(Map<String, dynamic> map) {
    return MeetingDetailsModel(
      id: map['id'] as String,
      hostId: map['hostId'] != null ? map['hostId'] as String : null,
      hostName: map['hostName'] != null ? map['hostName'] as String : null,
    );
  }
}
