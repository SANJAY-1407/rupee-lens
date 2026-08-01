class DenominationService {
  static List<String> calculate(int amount) {
    List<int> notes = [
      500,
      200,
      100,
      50,
      20,
      10,
      5,
      2,
      1,
    ];

    List<String> result = [];

    for (int note in notes) {
      if (amount >= note) {
        int count = amount ~/ note;
        amount %= note;

        result.add("$count × ₹$note notes");
      }
    }

    return result;
  }
}