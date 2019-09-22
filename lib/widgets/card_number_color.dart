import 'package:flutter/material.dart';

import 'package:superbingo/models/app_models/card.dart' as cardModel;
import 'package:superbingo/utils/card_utils.dart';

import 'package:vector_math/vector_math.dart' show radians;

class CardNumberColor extends StatelessWidget {
  const CardNumberColor({
    Key key,
    this.color,
    this.number,
    this.flip = false,
    this.isSmall = false,
  }) : super(key: key);

  final cardModel.CardColor color;
  final cardModel.CardNumber number;
  final bool flip;
  final bool isSmall;

  @override
  Widget build(BuildContext context) {
    final double iconSize = isSmall ? 16 : 24;
    final double fontSize = isSmall ? 14 : 18;

    return Transform.rotate(
      angle: radians(flip ? 180 : 0),
      child: Column(
        children: <Widget>[
          if (!flip) ...[
            Text(
              getTextByCardNumber(number),
              style: TextStyle(
                fontSize: fontSize,
                fontFamily: 'Georgia',
                color: getColorByCardColor(color),
              ),
            ),
            SizedBox(height: 4),
          ],
          Icon(
            getIconByCardColor(color),
            color: getColorByCardColor(color),
            size: iconSize,
          ),
          if (flip) ...[
            SizedBox(height: 4),
            Text(
              getTextByCardNumber(number),
              style: TextStyle(
                fontSize: fontSize,
                fontFamily: 'Georgia',
                color: getColorByCardColor(color),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
