import 'dart:core';
import 'package:prive/Models/Rooms/room_user.dart';

class Room {
  String? roomId;
  String? topic;
  String? description;
  RoomUser? owner;
  List<RoomUser>? speakers;
  List<RoomUser>? listeners;
  List<String>? roomContacts;
  List<RoomUser>? raisedHands;

  Room({
    this.roomId,
    this.topic,
    this.description,
    this.owner,
    this.speakers,
    this.listeners,
    this.roomContacts,
    this.raisedHands,
  });

  Room.fromJson(Map<String, dynamic> json) {
    roomId = json['roomId'] as String?;
    topic = json['topic'] as String?;
    description = json['description'] as String?;
    owner = json['owner'] as RoomUser?;
    speakers = json['speakers'] as List<RoomUser>?;
    listeners = json['listeners'] as List<RoomUser>?;
    roomContacts = json['roomContacts'] as List<String>?;
    raisedHands = json['raisedHands'] as List<RoomUser>?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['roomId'] = roomId;
    json['topic'] = topic;
    json['description'] = description;
    json['owner'] = owner;
    json['speakers'] = speakers;
    json['listeners'] = listeners;
    json['roomContacts'] = roomContacts;
    json['raisedHands'] = raisedHands;
    return json;
  }
}
