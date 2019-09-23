import 'dart:math';

import 'package:flutter/material.dart';

import 'package:superbingo/models/app_models/card.dart';
import 'package:superbingo/widgets/card_hand.dart';
import 'package:superbingo/widgets/play_card.dart';

import 'package:vector_math/vector_math.dart' show radians;

final List<GameCard> cards = [
  GameCard(
    color: CardColor.clover,
    number: CardNumber.ace,
  ),
  GameCard(
    color: CardColor.diamond,
    number: CardNumber.king,
  ),
  GameCard(
    color: CardColor.diamond,
    number: CardNumber.nine,
  ),
  GameCard(
    color: CardColor.clover,
    number: CardNumber.eight,
  ),
  GameCard(
    color: CardColor.heart,
    number: CardNumber.six,
  ),
  GameCard(
    color: CardColor.clover,
    number: CardNumber.queen,
  ),
  GameCard(
    color: CardColor.heart,
    number: CardNumber.seven,
  ),
  GameCard(
    color: CardColor.spade,
    number: CardNumber.six,
  ),
  GameCard(
    color: CardColor.clover,
    number: CardNumber.five,
  ),
];

class GamePage extends StatefulWidget {
  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Stack(
                  children: cards.map<Widget>((c) {
                    final rn = Random();
                    final index = cards.indexOf(c);
                    double angle = 1.0 + rn.nextInt(10);
                    double translationY, translationX;
                    if (c == cards.last) {
                      angle = radians(0);
                    } else {
                      angle = radians(angle);
                      angle = index % 2 == 0 ? angle : -angle;
                    }
                    translationY = 1.0 + rn.nextInt(5);
                    translationX = 1.0 + rn.nextInt(5);
                    if (rn.nextDouble() <= 0.5) {
                      translationX = -translationX;
                    }
                    if (rn.nextDouble() <= 0.5) {
                      translationY = -translationY;
                    }

                    return Transform(
                      child: Transform.rotate(
                        child: PlayCard(
                          height: 275,
                          width: 175,
                          card: c,
                          index: index,
                        ),
                        angle: angle,
                      ),
                      transform: Matrix4.identity()
                        ..translate(
                          translationX,
                          translationY,
                        ),
                    );
                  }).toList(),
                ),
              ),
            ),
            CardHand(
              cards: cards,
            ),
          ],
        ),
      ),
    );
  }
}
