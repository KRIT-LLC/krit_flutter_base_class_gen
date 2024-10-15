import 'package:analyzer/dart/element/element.dart';
import 'package:base_class_gen/sql_annotations/sql_annotations.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';

import 'base_class_visitor.dart';

final _primaryCheck = const TypeChecker.fromRuntime(PrimaryKey);
final _searchableCheck = const TypeChecker.fromRuntime(Searchable);
final _deleteByCheck = const TypeChecker.fromRuntime(DeleteBy);

class SQLModelGen extends GeneratorForAnnotation<Entity> {
  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    final visitor = BaseVisitor();
    var buffer = StringBuffer();
    element.visitChildren(visitor);
    var classElement = element as ClassElement;
    buffer.writeln('class ${visitor.className}Provider {');
    buffer.writeln('late final Database db;');
    buffer.writeln('${visitor.className}Provider();');
    //create table start
    buffer.writeln('Future createTable(Database db) async {');
    buffer.writeln('this.db = db;');
    buffer.writeln('if(await isTableExists(db)) return;');
    String buildString = '';
    for (var i = 0; i < classElement.fields.length; i++) {
      final type = classElement.fields[i].type.toString();
      var field = classElement.fields[i];
      if (type == 'String' || type == 'String?') {
        if (_primaryCheck.hasAnnotationOfExact(field)) {
          buildString += '${visitor.fieldNames[i]} TEXT PRIMARY KEY, ';
        } else {
          buildString += '${visitor.fieldNames[i]} TEXT, ';
        }
      } else if (type == 'int' || type == 'int?') {
        if (_primaryCheck.hasAnnotationOfExact(field)) {
          buildString += '${visitor.fieldNames[i]} INTEGER PRIMARY KEY, ';
        } else {
          buildString += '${visitor.fieldNames[i]} INTEGER, ';
        }
      } else if (type == 'double' || type == 'double?') {
        if (_primaryCheck.hasAnnotationOfExact(field)) {
          buildString += '${visitor.fieldNames[i]} REAL PRIMARY KEY, ';
        } else {
          buildString += '${visitor.fieldNames[i]} REAL, ';
        }
      } else if (type == 'bool' || type == 'bool?') {
        if (_primaryCheck.hasAnnotationOfExact(field)) {
          buildString += '${visitor.fieldNames[i]}_bool INTEGER PRIMARY KEY, ';
        } else {
          buildString += '${visitor.fieldNames[i]}_bool INTEGER, ';
        }
      }
    }
    buffer.writeln(
        'await db.execute(\'CREATE TABLE ${visitor.className} (${buildString.substring(0, buildString.length - 2)})\');');
    buffer.writeln('}');
    //create table finish
    buffer.writeln('Future<bool> isTableExists(Database db) async {');
    buffer.writeln('var result = await db.rawQuery(');
    buffer.writeln(
        '"SELECT name FROM sqlite_master WHERE type=\'table\' AND name=?",');
    buffer.writeln('[\'${visitor.className}\'],');
    buffer.writeln(');');
    buffer.writeln('return result.isNotEmpty;');
    buffer.writeln('}');

    // insert start
    buffer.writeln('Future<void> insert(${visitor.className} value) async {');
    buffer.writeln('await db.insert(\'${visitor.className}\', value.toMap(),');
    buffer.writeln('conflictAlgorithm: ConflictAlgorithm.replace);');
    buffer.writeln('}');
    //insert finish

    //query find start
    if (classElement.fields
        .any((e) => _searchableCheck.hasAnnotationOfExact(e))) {
      var searchableFields = classElement.fields
          .where((e) => _searchableCheck.hasAnnotationOfExact(e));
      for (var field in searchableFields) {
        buffer.writeln(
            'Future<List<${visitor.className}>> findBy${field.displayName.replaceFirst(field.displayName.split('').first, field.displayName.split('').first.toUpperCase())}(${field.type} ${field.displayName}) async {');
        buffer.writeln('var maps = await db.query(\'${visitor.className}\',');
        buffer.writeln('where:  \'${field.displayName} = ?\',');
        buffer.writeln('whereArgs: [${field.displayName}]);');
        buffer.writeln('return maps.map((e) => fromMap(e)).toList();');
        buffer.writeln('}');
      }
    }
    //query find finish

    //query all start
    buffer.writeln(
        'Future<List<${visitor.className}>> get${visitor.className}List() async {');
    buffer.writeln('var maps = await db.query(\'${visitor.className}\');');
    buffer.writeln('return maps.map((e) => fromMap(e)).toList();');
    buffer.writeln('}');
    //query all finish

    //clear start
    buffer.writeln('Future<void> clearTable() async {');
    buffer.writeln('await db.rawDelete(\'DELETE FROM ${visitor.className}\');');
    buffer.writeln('}');
    //clear finish
    //deleteBy start
    if (classElement.fields
        .any((e) => _deleteByCheck.hasAnnotationOfExact(e))) {
      var deleteByFields = classElement.fields
          .where((e) => _deleteByCheck.hasAnnotationOfExact(e));
      for (var field in deleteByFields) {
        buffer.writeln(
            'Future<void> deleteBy${field.displayName.replaceFirst(field.displayName.split('').first, field.displayName.split('').first.toUpperCase())}(${field.type} ${field.displayName}) async {');
        buffer.writeln(
            'await db.rawDelete(\'DELETE FROM ${visitor.className} WHERE ${field.displayName} = ?\', [${field.displayName}]);');
        buffer.writeln('}');
      }
    }
    //from map start
    buffer.writeln('${visitor.className} fromMap(Map<String,dynamic> map) =>');
    var constructors = classElement.constructors;
    List<ParameterElement> namedParameters = [];
    List<ParameterElement> normalParameters = [];
    if (constructors.isNotEmpty) {
      var mainConstructor = constructors.first;
      var parameters = mainConstructor.parameters;
      namedParameters = parameters.where((element) => element.isNamed).toList();
      normalParameters =
          parameters.where((element) => !element.isNamed).toList();
    }
    buffer.writeln('${visitor.className}(');
    for (var i = 0; i < normalParameters.length; i++) {
      var type = normalParameters[i].type;
      var name = normalParameters[i].name;
      if (type.toString().contains('List')) {
        buffer.writeln('$name: [],');
      } else if (type.toString() == 'String' || type.toString() == 'String?') {
        buffer.writeln('(map[\'$name\'] as String?) ?? \'\',');
      } else if (type.toString() == 'int?' || type.toString() == 'int') {
        buffer.writeln('(map[\'$name\'] as int?) ?? 0,');
      } else if (type.toString() == 'double?' || type.toString() == 'double') {
        buffer.writeln('(map[\'$name\'] as double?) ?? 0.0,');
      } else if (type.toString() == 'bool?' || type.toString() == 'bool') {
        buffer.writeln('map[\'${name}_bool\'] == 1,');
      } else {
        buffer.writeln('null,');
      }
    }
    if (namedParameters.isNotEmpty) {
      for (var i = 0; i < namedParameters.length; i++) {
        var type = namedParameters[i].type;
        var name = namedParameters[i].name;
        if (type.toString().contains('List')) {
          buffer.writeln('${namedParameters[i].name}: [],');
        } else if (type.toString() == 'String' ||
            type.toString() == 'String?') {
          buffer.writeln('$name: (map[\'$name\'] as String?) ?? \'\',');
        } else if (type.toString() == 'int?' || type.toString() == 'int') {
          buffer.writeln('$name: (map[\'$name\'] as int?) ?? 0,');
        } else if (type.toString() == 'double?' ||
            type.toString() == 'double') {
          buffer.writeln('$name: (map[\'$name\'] as double?) ?? 0.0,');
        } else if (type.toString() == 'bool?' || type.toString() == 'bool') {
          buffer.writeln('$name: map[\'${name}_bool\'] == 1,');
        } else {
          buffer.writeln('$name: null,');
        }
      }
    }
    buffer.writeln(');');
    //from map finish

    buffer.writeln('}');
    buffer
        .writeln('extension ${visitor.className}Ext on ${visitor.className} {');
    buffer.writeln('Map<String, dynamic> toMap() {');
    buffer.writeln('return {');
    for (var i = 0; i < classElement.fields.length; i++) {
      var field = classElement.fields[i];
      var type = field.type;
      if (!type.toString().contains('List')) {
        if (type.toString() == 'bool' || type.toString() == 'bool?') {
          buffer.writeln(
              '\'${field.name}_bool\': ${field.name} == true ? 1 : 0,');
        } else {
          if (type.toString() == 'double?' ||
              type.toString() == 'double' ||
              type.toString() == 'String' ||
              type.toString() == 'String?' ||
              type.toString() == 'int?' ||
              type.toString() == 'int') {
            buffer.writeln('\'${field.name}\': ${field.name},');
          }
        }
      }
    }
    buffer.writeln('};');
    buffer.writeln('}');
    buffer.writeln('}');

    return buffer.toString();
  }
}
