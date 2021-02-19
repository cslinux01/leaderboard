import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GamesModel {
  String name;
  String docId;
  GamesModel({@required this.name, @required this.docId});

  GamesModel.fromMap(Map<String, dynamic> map, String docId) {
    this.name = map['name'];
    this.docId = docId;
  }

  Map<String, dynamic> toMap() {
    return {'name': this.name};
  }

  static Stream<List<GamesModel>> get() {
    return FirebaseFirestore.instance.collection('leaderboard').snapshots().map(
        (event) =>
            event.docs.map((e) => GamesModel.fromMap(e.data(), e.id)).toList());
  }

  void save() {
    FirebaseFirestore.instance.collection('leaderboard').add(toMap());
  }
}

class LeaderboardModel {
  String username;
  int score;
  Timestamp createdAt;

  LeaderboardModel({this.username, this.score, this.createdAt});

  LeaderboardModel.fromMap(Map<String, dynamic> map) {
    this.username = map['username'];
    this.score = map['score'];
    this.createdAt = map['createdAt'];
  }

  Map<String, dynamic> toMap() {
    return {
      'username': this.username,
      'score': this.score,
      'createdAt': this.createdAt
    };
  }

  static Stream<List<LeaderboardModel>> get({@required String docId}) {
    return FirebaseFirestore.instance
        .collection('leaderboard')
        .doc(docId)
        .collection('users')
        .snapshots()
        .map((event) =>
            event.docs.map((e) => LeaderboardModel.fromMap(e.data())).toList());
  }

  void save({@required String docId}) {
    FirebaseFirestore.instance
        .collection('leaderboard')
        .doc(docId)
        .collection('users')
        .add(toMap());
  }
}
