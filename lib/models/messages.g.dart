// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messages.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MessagesAdapter extends TypeAdapter<Messages> {
  @override
  final int typeId = 2;

  @override
  Messages read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Messages(
      conversation: fields[0] as String?,
      conversationName: fields[1] as String?,
      whatsappGroup: fields[2] as String?,
      groupName: fields[3] as String?,
      messageAuthor: fields[4] as String?,
      sender: fields[5] as String?,
      recipient: fields[6] as String?,
      recipientName: fields[7] as String?,
      user: fields[8] as String?,
      messageContent: fields[9] as String?,
      mediaUrl: fields[10] as String?,
      timestamp: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Messages obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.conversation)
      ..writeByte(1)
      ..write(obj.conversationName)
      ..writeByte(2)
      ..write(obj.whatsappGroup)
      ..writeByte(3)
      ..write(obj.groupName)
      ..writeByte(4)
      ..write(obj.messageAuthor)
      ..writeByte(5)
      ..write(obj.sender)
      ..writeByte(6)
      ..write(obj.recipient)
      ..writeByte(7)
      ..write(obj.recipientName)
      ..writeByte(8)
      ..write(obj.user)
      ..writeByte(9)
      ..write(obj.messageContent)
      ..writeByte(10)
      ..write(obj.mediaUrl)
      ..writeByte(11)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessagesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
