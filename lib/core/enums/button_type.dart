enum ButtonType { outline, normal, text }

extension ButtonTypeValue on ButtonType {

  bool get isOutline => this == ButtonType.outline;
  bool get isNormal => this == ButtonType.normal;
  bool get isText => this == ButtonType.text;

}
