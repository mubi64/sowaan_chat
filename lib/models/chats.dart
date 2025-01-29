import 'package:hive/hive.dart';

part 'chats.g.dart';

@HiveType(typeId: 1)
class Chats {
  @HiveField(0)
  String? id;
  @HiveField(1)
  String? idName;
  @HiveField(2)
  String? recipientNumber;
  @HiveField(3)
  String? profilePhoto;
  @HiveField(4)
  String? lastMessage;
  @HiveField(5)
  String? timestamp;
  @HiveField(6)
  bool? isGroup;

  Chats(
      {this.id,
      this.idName,
      this.recipientNumber,
      this.profilePhoto,
      this.lastMessage,
      this.timestamp,
      this.isGroup});

  Chats.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    idName = json['id_name'];
    recipientNumber = json['recipient_number'];
    profilePhoto = json['profile_photo'];
    lastMessage = json['last_message'];
    timestamp = json['timestamp'];
    isGroup = json['isGroup'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['id_name'] = idName;
    data['recipient_number'] = recipientNumber;
    data['profile_photo'] = profilePhoto;
    data['last_message'] = lastMessage;
    data['timestamp'] = timestamp;
    data['isGroup'] = isGroup;
    return data;
  }
}
