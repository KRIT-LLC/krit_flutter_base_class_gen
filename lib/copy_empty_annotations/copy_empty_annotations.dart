class Copy {
  const Copy();
}

class Empty {
  const Empty();
}

class EnumField {
  const EnumField();
}

const enumField = EnumField();

class BaseClass {
  final bool? named;

  const BaseClass({this.named});
}

const baseClass = BaseClass(named: true);
