extension StringCasingExtension on String {
  String toCapitalized() {
    if (isEmpty) {
      return "";
    }
    final firstLetter = this[0].toUpperCase();
    if (length < 2) {
      return firstLetter;
    }
    final restOfLetter = substring(1).toLowerCase();
    return length > 0 ? '$firstLetter$restOfLetter' : '';
  }

  String toTitleCase() {
    return replaceAll(RegExp(' +'), ' ').split(' ').map((str) => str.toCapitalized).join(' ');
  }
}
