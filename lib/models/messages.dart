
import 'package:hive/hive.dart';

part 'messages.g.dart';

@HiveType(typeId: 2)
class Messages {
  @HiveField(0)
  String? conversation;
  @HiveField(1)
  String? conversationName;
  @HiveField(2)
  String? whatsappGroup;
  @HiveField(3)
  String? groupName;
  @HiveField(4)
  String? messageAuthor;
  @HiveField(5)
  String? sender;
  @HiveField(6)
  String? recipient;
  @HiveField(7)
  String? recipientName;
  @HiveField(8)
  String? user;
  @HiveField(9)
  String? messageContent;
  @HiveField(10)
  String? mediaUrl;
  @HiveField(11)
  String? timestamp;

  Messages(
      {this.conversation,
      this.conversationName,
      this.whatsappGroup,
      this.groupName,
      this.messageAuthor,
      this.sender,
      this.recipient,
      this.recipientName,
      this.user,
      this.messageContent,
      this.mediaUrl,
      this.timestamp});

  Messages.fromJson(Map<String, dynamic> json) {
    conversation = json['conversation'];
    conversationName = json['conversation_name'];
    whatsappGroup = json['whatsapp_group'];
    groupName = json['group_name'];
    messageAuthor = json['message_author'];
    sender = json['sender'];
    recipient = json['recipient'];
    recipientName = json['recipient_name'];
    user = json['user'];
    messageContent = json['message_content'];
    mediaUrl = json['media_url'];
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['conversation'] = conversation;
    data['conversation_name'] = conversationName;
    data['whatsapp_group'] = whatsappGroup;
    data['group_name'] = groupName;
    data['message_author'] = messageAuthor;
    data['sender'] = sender;
    data['recipient'] = recipient;
    data['recipient_name'] = recipientName;
    data['user'] = user;
    data['message_content'] = messageContent;
    data['media_url'] = mediaUrl;
    data['timestamp'] = timestamp;
    return data;
  }
}
