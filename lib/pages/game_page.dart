import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:superbingo/bloc/blocs/current_game_bloc.dart';
import 'package:superbingo/bloc/events/current_game_events.dart';
import 'package:superbingo/bloc/states/current_game_states.dart';
import 'package:superbingo/models/app_models/card.dart';
import 'package:superbingo/utils/dialogs.dart';
import 'package:superbingo/widgets/card_scroll_view.dart';
import 'package:superbingo/widgets/card_stack.dart';
import 'package:superbingo/widgets/avatars/player_avatars.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  OverlayEntry startingOverlay;

  @override
  void dispose() {
    hideStartingOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentGameBloc = BlocProvider.of<CurrentGameBloc>(context);
    final height = MediaQuery.of(context).size.height;
    final playerAvatarBottomPosition = (height - kToolbarHeight) / 2.1;

    return WillPopScope(
      onWillPop: () async {
        final result = await Dialogs.showDecisionDialog(
          context,
          content: 'Wollen Sie wirklich das Spiel verlassen.',
        );
        if (result) {
          currentGameBloc.add(LeaveGame());
        }
        return Future(() => result);
      },
      child: MultiBlocListener(
        listeners: [
          BlocListener<CurrentGameBloc, CurrentGameState>(
            bloc: currentGameBloc,
            listener: (context, state) {
              if (state is PlayerJoined && mounted) {
                showSimpleNotification(
                  Text('${state.player?.name} ist dem Spiel beigetreten.'),
                  foreground: Colors.white,
                );
              } else if (state is PlayerLeaved && mounted) {
                showSimpleNotification(
                  Text('${state.player?.name} hat das Spiel verlassen.'),
                  foreground: Colors.white,
                );
              } else if (state is CurrentGameStarting && mounted) {
                showStartingOverlay(context);
              } else if (state is CurrentGameFinished) {
                Navigator.of(context).pop();
              } else if (mounted) {
                hideStartingOverlay();
              }
            },
          ),
        ],
        child: BlocBuilder<CurrentGameBloc, CurrentGameState>(
          bloc: currentGameBloc,
          builder: (context, state) {
            String title;
            List<GameCard> playedCards, unplayedCards;
            if (state is CurrentGameLoaded) {
              title = state.game.name;
              playedCards = state.playedCards;
              unplayedCards = state.unplayedCards;
            } else if (state is CurrentGameWaitingForPlayer) {
              title = state.game.name;
              playedCards = state.game.playedCardStack.toList();
              unplayedCards = state.game.unplayedCardStack.toList();
            } else {
              title = 'Aktuelles Spiel';
              playedCards = [];
              unplayedCards = [];
            }

            return SlidingUpPanel(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18.0),
                topRight: Radius.circular(18.0),
              ),
              color: Theme.of(context).canvasColor,
              minHeight: state is CurrentGameLoaded ? 125 : 0,
              // minHeight: 125,
              maxHeight:
                  MediaQuery.of(context).size.height - kToolbarHeight - 20,
              // parallaxEnabled: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              isDraggable: state is CurrentGameLoaded,
              // isDraggable: true,
              body: Scaffold(
                backgroundColor: Colors.deepOrangeAccent,
                endDrawer: Drawer(
                  child: Column(
                    children: <Widget>[],
                  ),
                ),
                appBar: AppBar(
                  backgroundColor: Colors.deepOrangeAccent,
                  title: Text(title),
                ),
                body: SafeArea(
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        top: 80,
                        left: 76,
                        right: 76,
                        bottom: playerAvatarBottomPosition,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Expanded(
                                child: CardStack(
                                  type: CardStackType.unplayedCards,
                                  cards: unplayedCards,
                                  // cards: defaultCardDeck,
                                ),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                child: CardStack(
                                  type: CardStackType.playedCards,
                                  cards: playedCards,
                                  // cards: defaultCardDeck,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // const CardHand(),
                      const PlayerAvatars(),
                      Positioned(
                        bottom: MediaQuery.of(context).size.height / 3,
                        right: 8,
                        child: FloatingActionButton(
                          backgroundColor: Colors.orange,
                          child: Icon(Icons.flag),
                          onPressed: () {},
                        ),
                      ),
                      if (state is CurrentGameWaitingForPlayer) ...[
                        if (state.self.isHost)
                          Positioned(
                            bottom: 2,
                            left: 8,
                            right: 8,
                            child: Center(
                              child: RaisedButton(
                                onPressed: () {
                                  currentGameBloc.add(StartGame(
                                    gameId: state.game.gameID,
                                    self: state.self,
                                  ));
                                },
                                child: Text('Spiel starten'),
                              ),
                            ),
                          ),
                        if (!state.self.isHost)
                          Positioned(
                            bottom: 8,
                            left: 8,
                            right: 8,
                            child: Center(
                              child: Text('Warten auf weitere Spieler...'),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
              panel: CardScrollView(),
            );
          },
        ),
      ),
    );
  }

  void showStartingOverlay(BuildContext context) {
    startingOverlay = OverlayEntry(
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text('Das Spiel wird gestartet'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(startingOverlay);
  }

  void hideStartingOverlay() {
    startingOverlay?.remove();
    startingOverlay = null;
  }
}
