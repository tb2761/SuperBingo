import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:superbingo/blocs/events/game_events.dart';
import 'package:superbingo/blocs/game_bloc.dart';
import 'package:superbingo/blocs/states/game_states.dart';

class NewGamePage extends StatefulWidget {
  @override
  _NewGamePageState createState() => _NewGamePageState();
}

class _NewGamePageState extends State<NewGamePage> {
  final formKey = GlobalKey<FormState>();
  bool isValid, isPublic, showStartGame, isDisabled;
  OverlayEntry _gameCreationOverlay;

  String name;
  int maxPlayer, cardAmount;

  FocusScopeNode _node = FocusScopeNode();

  @override
  void initState() {
    super.initState();
    isValid = false;
    isPublic = false;
    showStartGame = false;
    isDisabled = false;
  }

  @override
  void dispose() {
    hideGameCreationOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameBloc = BlocProvider.of<GameBloc>(context);

    final border = OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.white,
        width: 1.5,
      ),
    );

    return BlocListener<GameBloc, GameState>(
      listener: (context, state) {
        if (state is GameCreating) {
          showGameCreationOverlay(context);
        } else if (state is GameCreated) {
          hideGameCreationOverlay();
        }
      },
      child: BlocBuilder<GameBloc, GameState>(
        builder: (context, state) {
          Widget body;

          if (state is WaitingGameConfigInput) {
            body = Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: FocusScope(
                    node: _node,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          decoration: InputDecoration(
                            border: border,
                            enabledBorder: border,
                            focusedBorder: border,
                            labelText: 'Name',
                            hintText: 'Gib den Spiel einen Namen',
                          ),
                          validator: (text) =>
                              text.isNotEmpty ? null : 'Name is required',
                          onEditingComplete: () => _node.nextFocus(),
                          onSaved: (text) => name = text,
                          enabled: !isDisabled,
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          decoration: InputDecoration(
                            border: border,
                            enabledBorder: border,
                            focusedBorder: border,
                            labelText: 'Maximale Spieleranzahl (Default: 6)',
                            hintText: 'Gib eine Zahl zwischen 4-8 an',
                          ),
                          validator: (text) {
                            final parsedAmount = int.tryParse(text) ?? 0;
                            if (parsedAmount < 2 || parsedAmount > 6) {
                              return 'Es nur Zahlen zwischen 2 und 6 erlaubt';
                            } else if (text.isEmpty || parsedAmount > 2) {
                              return null;
                            } else {
                              return 'Es sind nur Zahlen erlaubt';
                            }
                          },
                          onSaved: (text) =>
                              maxPlayer = int.tryParse(text) ?? 6,
                          onEditingComplete: () => _node.nextFocus(),
                          enabled: !isDisabled,
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          decoration: InputDecoration(
                            border: border,
                            enabledBorder: border,
                            focusedBorder: border,
                            labelText: 'Anzahl der Karten',
                          ),
                          validator: (text) {
                            final parsedAmount = int.tryParse(text) ?? 0;
                            if (text.isEmpty || parsedAmount > 2) {
                              return null;
                            } else {
                              return 'Es sind nur Zahlen erlaubt';
                            }
                          },
                          onEditingComplete: () => _node.unfocus(),
                          onSaved: (text) =>
                              cardAmount = calculateCardAmount(text),
                          enabled: !isDisabled,
                        ),
                        SizedBox(height: 8),
                        CheckboxListTile(
                          title: Text('Öffentliches Spiel'),
                          value: isPublic,
                          onChanged: (value) => !isDisabled
                              ? setState(() => isPublic = value)
                              : null,
                          activeColor: Colors.deepOrange,
                        ),
                        if (isValid)
                          Padding(
                            padding: EdgeInsets.only(top: 25),
                            child: RaisedButton(
                              child: Text('Spiel erstellen'),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                              onPressed: () async {
                                final success = true;
                                gameBloc.add(CreateGame(
                                  isPublic: isPublic,
                                  maxPlayer: maxPlayer,
                                  name: name,
                                  cardAmount: cardAmount,
                                ));
                                setState(() {
                                  showStartGame = success;
                                  isValid = !success;
                                  isDisabled = success;
                                });
                              },
                            ),
                          ),
                        if (showStartGame && !isValid) ...[
                          Padding(
                            padding: EdgeInsets.only(top: 25),
                            child: RaisedButton(
                              child: Text('Spiel starten'),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                              onPressed: () async {
                                gameBloc.startGame();
                                Navigator.of(context)
                                    .pushReplacementNamed('/game');
                              },
                            ),
                          ),
                          StreamBuilder<String>(
                            stream: gameBloc.gameLinkStream,
                            builder: (context, snapshot) {
                              final canShare =
                                  snapshot.hasData && snapshot.data.isNotEmpty;

                              return Padding(
                                padding: EdgeInsets.only(top: 25),
                                child: RaisedButton(
                                  child: Text('Freunde einladen'),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  onPressed: canShare
                                      ? () async => Share.share(
                                            snapshot.data,
                                            subject:
                                                'SuperBingo Spieleinladung',
                                          )
                                      : null,
                                ),
                              );
                            },
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else if (state is GameCreated) {
            body = Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: ListView.builder(
                itemBuilder: (context, index) => ListTile(
                  title: Text(
                    state.player.elementAt(index).name,
                  ),
                  leading: CircleAvatar(
                    child: Text(
                      state.player
                          .elementAt(index)
                          .name
                          .substring(0, 1)
                          .toUpperCase(),
                    ),
                  ),
                ),
                itemCount: state.player.length,
              ),
            );
          }

          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              title: Text('Neues Spiel'),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.check),
                  onPressed: !isDisabled
                      ? () {
                          if (formKey.currentState.validate()) {
                            formKey.currentState.save();
                            setState(() => isValid = true);
                          }
                        }
                      : null,
                ),
              ],
            ),
            body: body,
          );
        },
      ),
    );
  }

  int calculateCardAmount(String amountString) {
    int amount = int.tryParse(amountString);
    if (amount == null) {
      amount = ((maxPlayer % 4) + 1) * 32;
    }
    return amount;
  }

  void showGameCreationOverlay(BuildContext context) {
    _gameCreationOverlay = OverlayEntry(
      builder: (context) => Stack(
        children: <Widget>[
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
          ),
          Center(
            child: Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_gameCreationOverlay);
  }

  void hideGameCreationOverlay() {
    if (_gameCreationOverlay != null) {
      _gameCreationOverlay.remove();
      _gameCreationOverlay = null;
    }
  }
}
