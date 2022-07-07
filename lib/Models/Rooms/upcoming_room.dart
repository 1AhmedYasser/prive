import 'package:prive/Models/Rooms/room_user.dart';

class UpcomingRoom {
  String? roomId;
  String? topic;
  String? description;
  String? time;
  RoomUser? owner;
  List<String>? roomContacts;

  UpcomingRoom(
      {this.roomId,
      this.topic,
      this.description,
      this.time,
      this.owner,
      this.roomContacts});

  UpcomingRoom.fromJson(Map<String, dynamic> json) {
    roomId = json['roomId'] as String?;
    topic = json['topic'] as String?;
    description = json['description'] as String?;
    time = json['time'] as String?;
    owner = json['owner'] as RoomUser?;
    roomContacts = json['roomContacts'] as List<String>?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['roomId'] = roomId;
    json['topic'] = topic;
    json['description'] = description;
    json['time'] = time;
    json['owner'] = owner;
    json['roomContacts'] = roomContacts;
    return json;
  }
}
