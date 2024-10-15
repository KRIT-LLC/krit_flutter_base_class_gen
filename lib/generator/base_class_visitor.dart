
import 'package:analyzer/dart/element/visitor.dart';

import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

import '../copy_empty_annotations/copy_empty_annotations.dart';

class BaseVisitor extends SimpleElementVisitor<void> {
  String className = '';

  String constructor = '';
  List<String> fields = [];
  List<String> fieldNames = [];
  List<String> typeNames = [];
  List<String> nullableFields = [];
  List<String?> types = [];
  String annotation = '';
  @override
  void visitConstructorElement(ConstructorElement element) {
    final elementReturnType = element.type.returnType.toString();
    className = elementReturnType.replaceFirst('*', '');

  }

  @override
  void visitFieldElement(FieldElement element) {
    var instanceName = element.name;
    fields.add('${element.declaration};');
    fieldNames.add(instanceName);
    typeNames.add(element.type.toString());
    types.add(element.type.element?.runtimeType.toString());
    nullableFields.add('${element.type}? $instanceName');
  }

}
