import 'package:analyzer/dart/element/element.dart';
import 'package:base_class_gen/copy_empty_annotations/copy_empty_annotations.dart';
import 'package:source_gen/source_gen.dart';
import 'package:build/build.dart';

import 'base_class_visitor.dart';

class CopyEmptyGen extends GeneratorForAnnotation<BaseClass> {
  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    final visitor = BaseVisitor();
    var buffer = StringBuffer();
    var classElement = element as ClassElement;
    element.visitChildren(visitor);

    final slashedName = '_\$${visitor.className}';
    var constructor = classElement.constructors.first;
    var namedParams = constructor.parameters.where((e) => e.isNamed).toList();
    var posParams = constructor.parameters.where((e) => !e.isNamed).toList();
    buffer.writeln('${visitor.className} ${slashedName}Empty(){');
    buffer.writeln('return ${visitor.className}(');
    for (var item in posParams) {
      var type = item.type;
      var name = item.name;
      if (type.toString().contains('List')) {
        buffer.writeln('$name: [],');
      } else if (type.toString() == 'String' || type.toString() == 'String?') {
        buffer.writeln('\'\',');
      } else if (type.toString() == 'int?' || type.toString() == 'int') {
        buffer.writeln('0,');
      } else if (type.toString() == 'double?' || type.toString() == 'double') {
        buffer.writeln('0.0');
      } else if (type.toString() == 'bool?' || type.toString() == 'bool') {
        buffer.writeln('false,');
      } else if (type.toString() == 'EnumElementImpl') {
        print('unhandled enum $type');
      } else {
        print('unhandled type $type');
        buffer.writeln('null,');
      }
    }
    for (var i = 0; i < namedParams.length; i++) {
      var type = namedParams[i].type;
      var name = namedParams[i].name;
      if (type.toString().contains('List')) {
        buffer.writeln('${namedParams[i].name}: [],');
      } else if (type.toString() == 'String' || type.toString() == 'String?') {
        buffer.writeln('$name: \'\',');
      } else if (type.toString() == 'int?' || type.toString() == 'int') {
        buffer.writeln('$name: 0,');
      } else if (type.toString() == 'double?' || type.toString() == 'double') {
        buffer.writeln('$name: 0.0,');
      } else if (type.toString() == 'bool?' || type.toString() == 'bool') {
        buffer.writeln('$name: false,');
      } else {
        print('unhandled enum $type');
        buffer.writeln('$name: ${type}.empty(),');
      }
    }
    buffer.writeln(');}');

    buffer.writeln(
        'extension ${visitor.className}Value on ${visitor.className} {');
    buffer.writeln('${visitor.className} copy({');
    for (var item in posParams) {
      var type = item.type;
      var name = item.name;
      buffer.writeln(
          '${type.toString().endsWith('?') ? '$type' : '$type?'} $name,');
    }
    for (var item in namedParams) {
      var type = item.type;
      var name = item.name;
      buffer.writeln(
          '${type.toString().endsWith('?') ? '$type' : '$type?'} $name,');
    }
    buffer.writeln('}) {');

    buffer.writeln('return ${visitor.className}(');
    for (var item in posParams) {
      var name = item.name;
      buffer.writeln('$name ?? this.$name,');
    }
    for (var item in namedParams) {
      var name = item.name;
      buffer.writeln('$name: $name ?? this.$name,');
    }
    buffer.writeln(');}');

    buffer.writeln('}');
    return buffer.toString();
  }
}
