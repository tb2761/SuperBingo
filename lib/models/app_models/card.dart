class GameCard {
  final CardColor color;
  final CardNumber number;
  final SpecialRule rule;

  GameCard({this.color, this.number}) : rule = ruleFromNumber(number);

  factory GameCard.fromDefinitonString(String definition) {
    final parts = definition.split('|');
    

    return GameCard();
  }

  static SpecialRule ruleFromNumber(CardNumber number) {
    switch (number) {
      case CardNumber.eight:
        return SpecialRule.skip;
      case CardNumber.nine:
        return SpecialRule.reverse;
      case CardNumber.jack:
      case CardNumber.joker:
        return SpecialRule.joker;
      case CardNumber.seven:
        return SpecialRule.plusTwo;
      default:
        return null;
    }
  }
}

enum CardColor { heart, diamond, spade, clover }
enum CardNumber { five, six, seven, eight, nine, jack, queen, king, ace, joker }
enum SpecialRule { reverse, skip, joker, plusTwo }
