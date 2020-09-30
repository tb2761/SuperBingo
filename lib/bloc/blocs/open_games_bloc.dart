import 'dart:async';

import 'package:flutter/services.dart';

import 'package:firedart/firedart.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:rxdart/subjects.dart';

import '../../models/app_models/game.dart';

class PublicGamesBloc {
  StreamSubscription _gamesSub;

  PublicGamesBloc() {
    _publicGamesController = BehaviorSubject<List<Game>>();
    initListener();
  }

  BehaviorSubject<List<Game>> _publicGamesController;

  Sink get _publicGamesSink => _publicGamesController.sink;
  Stream<List<Game>> get publicGamesStream => _publicGamesController.stream;

  Future<void> getPublicGames() async {
    final dbGames = await Firestore.instance.collection('games').get();
    _publicGamesSink.add(null);
    _handleSnapshot(dbGames);
  }

  void initListener() {
    final dbGames = Firestore.instance.collection('games');
    _gamesSub = dbGames.stream
        .listen(_handleSnapshot); // snapshots().listen(_handleSnapshot);
  }

  void _handleSnapshot(List<Document> snapshot) {
    try {
      final docs = snapshot;
      final games = docs.map<Game>((g) => Game.fromJson(g.map)).toList();
      final publicGames = <Game>[];
      for (final game in games) {
        if (game.isPublic == true && game.state == GameState.waitingForPlayer) {
          publicGames.add(game);
        }
      }
      _publicGamesSink.add(publicGames);
    } on PlatformException catch (e) {
      if (e.message.contains('PERMISSION_DENIED')) {
        _publicGamesSink.add(PermissionError(
            e.message.replaceAll('PERMISSION_DENIED:', '').trim()));
      } else {
        _publicGamesSink.add(Error());
      }
    } on dynamic catch (e, s) {
      Crashlytics.instance.recordError(e, s);
      _publicGamesSink.add(Error());
    }
  }

  void dispose() {
    _publicGamesController?.close();
    _gamesSub?.cancel();
  }
}

class PermissionError extends Error {
  final String message;

  PermissionError(this.message);
}
