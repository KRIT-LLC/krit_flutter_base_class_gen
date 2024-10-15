extension StrBaseCalss on String {
  bool get hasSpacer => contains(' ');

  bool get hasNumerics => double.tryParse(this) != null;

  String format(String param) {
    return replaceAll('{}', param);
  }

  bool containsValue(String? value) {
    return getSearchString().contains(value.orEmpty.getSearchString());
  }

  bool get isValid => replaceAll(' ', '').replaceAll('\n', '').isNotEmpty;

  String intFormat(int param) {
    return replaceAll('{}', '$param');
  }

  String getSearchString() {
    return toLowerCase().replaceAll(' ', '');
  }

  String clearDuplicates(String param) {
    return replaceFirst(param, ' ');
  }
}

extension StringBaseClassNull on String? {
  String get orEmpty => this ?? '';
}
