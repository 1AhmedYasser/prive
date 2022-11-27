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
  List<RoomUser>? kickedListeners;
  List<RoomUser>? upgradedListeners;

  Room({
    this.roomId,
    this.topic,
    this.description,
    this.owner,
    this.speakers,
    this.listeners,
    this.roomContacts,
    this.raisedHands,
    this.kickedListeners,
    this.upgradedListeners,
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
    kickedListeners = json['kickedListeners'] as List<RoomUser>?;
    upgradedListeners = json['upgradedListeners'] as List<RoomUser>?;
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
    json['kickedListeners'] = kickedListeners;
    json['upgradedListeners'] = upgradedListeners;
    return json;
  }
}
