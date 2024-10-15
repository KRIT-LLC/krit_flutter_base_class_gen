
extension Bnull on bool? {
  bool get orFalse => this ?? false;
  bool get orTrue => this ?? true;
}
