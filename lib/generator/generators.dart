import 'package:base_class_gen/generator/copy_empty_gen.dart';
import 'package:base_class_gen/generator/sql_md_gen.dart';
import 'package:source_gen/source_gen.dart';
import 'package:build/build.dart';

Builder baseClassGeneratorBuilder(BuilderOptions options) =>
    SharedPartBuilder([CopyEmptyGen()], 'd');

Builder sqlModelGen(BuilderOptions options) =>
    SharedPartBuilder([SQLModelGen()], 'b');