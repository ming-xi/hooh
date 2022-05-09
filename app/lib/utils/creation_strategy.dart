class CreationStrategy {
  static double calculateFontSize(String text) {
    if (text.length < 3) {
      return 100;
    } else if (text.length < 7) {
      return 52;
    } else if (text.length < 19) {
      return 36;
    } else if (text.length < 55) {
      return 26;
    } else {
      return 18;
    }
  }

  static double calculateLineHeight(String text) {
    if (text.length < 3) {
      return 1.5;
    } else if (text.length < 7) {
      return 1.5;
    } else if (text.length < 19) {
      return 1.25;
    } else if (text.length < 55) {
      return 1.25;
    } else {
      return 1;
    }
  }

  static const FONT_LIST = ["Linotte", "Pacifico"];
}
