// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// https://github.com/flutter/engine/blob/main/ci/builders/README.md

/// Each build config file contains a top-level json map with the following
/// fields:
/// {
///    "builds": [],
///    "tests": [],
///    "generators": {
///      "tasks": []
///    },
///    "archives": []
/// }
class BuildConfig {
  factory BuildConfig.fromJson(String name, Map<String, Object?> map) {
    final StringBuffer errorBuffer = StringBuffer();
    final List<GlobalBuild>? builds = objListOfJson<GlobalBuild>(
      map, 'builds', errorBuffer, GlobalBuild.fromJson,
    );
    final List<GlobalTest>? tests = objListOfJson<GlobalTest>(
      map, 'tests', errorBuffer, GlobalTest.fromJson,
    );
    late final List<TestTask>? generators;
    if (map['generators'] == null) {
      generators = <TestTask>[];
    } else if (map['generators'] is! Map<String, Object?>) {
      errorBuffer.writeln('"generators" field is malformed.');
      generators = null;
    } else {
      generators = objListOfJson(
        map['generators']! as Map<String, Object?>,
        'tasks',
        errorBuffer,
        TestTask.fromJson,
      );
    }
    if (builds == null || tests == null || generators == null) {
      return BuildConfig._invalid(name, errorBuffer.toString());
    }
    return BuildConfig._(name, builds, tests, generators);
  }


  BuildConfig._(this.name, this.builds, this.tests, this.generators) :
    valid = true, error = null;

  BuildConfig._invalid(this.name, this.error) :
    valid = false,
    builds = <GlobalBuild>[],
    tests = <GlobalTest>[],
    generators = <TestTask>[];

  final bool valid;
  final String? error;
  final String name;
  final List<GlobalBuild> builds;
  final List<GlobalTest> tests;
  final List<TestTask> generators;
  // TODO(zanderso): archives.
  // Global "archives"
  // "archives": [
  //   {
  //     "source": "",
  //     "destination": "",
  //     "realm": ""
  //   },
  // ]

  String check(String path) {
    if (!valid) {
      return '$path\n${error!}';
    }
    final StringBuffer errorBuffer = StringBuffer();
    for (int i = 0; i < builds.length; i++) {
      final GlobalBuild build = builds[i];
      errorBuffer.write(build.check('$path/builds[$i]'));
    }
    for (int i = 0; i < tests.length; i++) {
      final GlobalTest test = tests[i];
      errorBuffer.write(test.check('$path/tests[$i]'));
    }
    for (int i = 0; i < generators.length; i++) {
      final TestTask task = generators[i];
      errorBuffer.write(task.check('$path/generators/tasks[$i]'));
    }
    return errorBuffer.toString();
  }

  @override
  String toString() {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln(name);
    buffer.writeln('  Builds:');
    for (final GlobalBuild build in builds) {
      buffer.writeln('    ${build.name}');
    }
    buffer.writeln('  Tests:');
    for (final GlobalTest test in tests) {
      buffer.writeln('    ${test.name}');
    }
    buffer.writeln('  Generators:');
    for (final TestTask task in generators) {
      buffer.writeln('    ${task.name}');
    }
    return buffer.toString();
  }
}

/// "builds" contains a list of maps with fields like:
/// {
///   "name": "",
///   "gn": [""],
///   "ninja": {},
///   "tests": [],
///   "generators": {
///     "tasks": []
///   }, (optional)
///   "archives": [],
///   "drone_dimensions": [""],
///   "gclient_variables": {}
/// }
class GlobalBuild {
  factory GlobalBuild.fromJson(Map<String, Object?> map) {
    final StringBuffer errorBuffer = StringBuffer();
    final String? name = stringOfJson(map, 'name', errorBuffer);
    final List<String>? gn = stringListOfJson(map, 'gn', errorBuffer);
    final List<BuildTest>? tests = objListOfJson(
      map, 'tests', errorBuffer, BuildTest.fromJson,
    );
    final List<BuildArchive>? archives = objListOfJson(
      map, 'archives', errorBuffer, BuildArchive.fromJson,
    );
    final List<String>? droneDimensions = stringListOfJson(
      map, 'drone_dimensions', errorBuffer,
    );

    late final BuildNinja? ninja;
    if (map['ninja'] == null) {
      ninja = BuildNinja.nop();
    } else if (map['ninja'] is! Map<String, Object?>) {
      ninja = null;
    } else {
      ninja = BuildNinja.fromJson(map['ninja']! as Map<String, Object?>);
    }
    if (ninja == null) {
      errorBuffer.writeln('"ninja" field is malformed.');
    }

    late final List<BuildTask>? generators;
    if (map['generators'] == null) {
      generators = <BuildTask>[];
    } else if (map['generators'] is! Map<String, Object?>) {
      errorBuffer.writeln('"generators" field is malformed.');
      generators = null;
    } else {
      generators = objListOfJson(
        map['generators']! as Map<String, Object?>,
        'tasks',
        errorBuffer,
        BuildTask.fromJson,
      );
    }

    if (name == null ||
        gn == null ||
        ninja == null ||
        archives == null ||
        tests == null ||
        generators == null ||
        droneDimensions == null) {
      return GlobalBuild._invalid(errorBuffer.toString());
    }
    return GlobalBuild._(
      name, gn, ninja, tests, generators, archives, droneDimensions,
    );
  }

  GlobalBuild._(
    this.name,
    this.gn,
    this.ninja,
    this.tests,
    this.generators,
    this.archives,
    this.droneDimensions,
  ) : valid = true, error = null;

  GlobalBuild._invalid(this.error) :
    valid = false,
    name = '',
    gn = <String>[],
    ninja = BuildNinja.nop(),
    tests = <BuildTest>[],
    generators = <BuildTask>[],
    archives = <BuildArchive>[],
    droneDimensions = <String>[];

  final bool valid;
  final String? error;
  final String name;
  final List<String> gn;
  final BuildNinja ninja;
  final List<BuildTest> tests;
  final List<BuildTask> generators;
  final List<BuildArchive> archives;
  final List<String> droneDimensions;
  // TODO(zanderso): gclient_variables

  String check(String path) {
    if (!valid) {
      return '$path\n${error!}';
    }
    final StringBuffer errorBuffer = StringBuffer();
    errorBuffer.write(ninja.check('$path/ninja'));
    for (int i = 0; i < tests.length; i++) {
      final BuildTest test = tests[i];
      errorBuffer.write(test.check('$path/tests[$i]'));
    }
    for (int i = 0; i < generators.length; i++) {
      final BuildTask task = generators[i];
      errorBuffer.write(task.check('$path/generators/tasks[$i]'));
    }
    for (int i = 0; i < archives.length; i++) {
      final BuildArchive archive = archives[i];
      errorBuffer.write(archive.check('$path/archives[$i]'));
    }
    return errorBuffer.toString();
  }

  @override
  String toString() => toStringIndented(0);

  String toStringIndented(int spaces) {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln(name);
    buffer.write(' '*spaces);
    buffer.write('gn');
    for (final String gnArg in gn) {
      buffer.write(' ');
      buffer.write(gnArg);
    }
    buffer.writeln();
    buffer.write(' '*spaces);
    buffer.writeln(ninja);
    for (final BuildTest test in tests) {
      buffer.write(' '*spaces);
      buffer.writeln('-> Test $test');
    }
    for (final BuildTask task in generators) {
      buffer.write(' '*spaces);
      buffer.writeln('-> Generator $task');
    }
    return buffer.toString();
  }
}

/// "builds" -> "ninja" contains a map with fields like:
/// {
///   "config": "",
///   "targets": [""]
/// },
class BuildNinja {
  factory BuildNinja.fromJson(Map<String, Object?> map) {
    final StringBuffer errorBuffer = StringBuffer();
    final String? config = stringOfJson(map, 'config', errorBuffer);
    final List<String>? targets = stringListOfJson(map, 'targets', errorBuffer);
    if (config == null || targets == null) {
      return BuildNinja._invalid(errorBuffer.toString());
    }
    return BuildNinja._(config, targets);
  }

  BuildNinja._(this.config, this.targets) : valid = true, error = null;

  BuildNinja._invalid(this.error) :
    valid = false,
    config = '',
    targets = <String>[];

  BuildNinja.nop() :
    valid = true,
    error = null,
    config = '',
    targets = <String>[];

  final bool valid;
  final String? error;
  final String config;
  final List<String> targets;

  String check(String path) {
    if (!valid) {
      return '$path\n${error!}';
    }
    return '';
  }

  @override
  String toString() => toStringIndented(0);

  String toStringIndented(int spaces) {
    if (config.isEmpty) {
      return '';
    }
    final StringBuffer buffer = StringBuffer();
    buffer.write('ninja');
    buffer.write(' -C out/');
    buffer.write(config);
    for (final String target in targets) {
      buffer.write(' ');
      buffer.write(target);
    }
    return buffer.toString();
  }
}

/// "builds" -> "tests" contains a list of maps with fields like:
/// {
///  "language": "",
///  "name": "",
///  "parameters": [""],
///  "script": "",
///  "contexts": [""]
/// }
class BuildTest {
  factory BuildTest.fromJson(Map<String, Object?> map) {
    final StringBuffer errorBuffer = StringBuffer();
    final String? name = stringOfJson(map, 'name', errorBuffer);
    final String? language = stringOfJson(map, 'language', errorBuffer);
    final String? script = stringOfJson(map, 'script', errorBuffer);
    final List<String>? parameters = stringListOfJson(
      map, 'parameters', errorBuffer,
    );
    final List<String>? contexts = stringListOfJson(
      map, 'contexts', errorBuffer,
    );
    if (name == null ||
        language == null ||
        script == null ||
        parameters == null ||
        contexts == null) {
      return BuildTest._invalid(errorBuffer.toString());
    }
    return BuildTest._(name, language, script, parameters, contexts);
  }

  BuildTest._(
    this.name,
    this.language,
    this.script,
    this.parameters,
    this.contexts,
  ) : valid = true, error = null;

  BuildTest._invalid(this.error) :
    valid = false,
    name = '',
    language = '',
    script = '',
    parameters = <String>[],
    contexts = <String>[];

  final bool valid;
  final String? error;
  final String name;
  final String language;
  final String script;
  final List<String> parameters;
  final List<String> contexts;

  String check(String path) {
    if (!valid) {
      return '$path\n${error!}';
    }
    return '';
  }

  @override
  String toString() => toStringIndented(0);

  String toStringIndented(int spaces) {
    final StringBuffer buffer = StringBuffer();
    buffer.write('"$name": ');
    buffer.write(language);
    buffer.write(' ');
    buffer.write(script);
    for (final String parameter in parameters) {
      buffer.write(' ');
      buffer.write(parameter);
    }
    return buffer.toString();
  }
}

/// "builds" -> "generators" is a map containing a single property "tasks",
/// which is a list of maps with fields like:
/// {
///   "name": "",
///   "parameters": [""],
///   "script": [""],
///   "language": ""
/// }
class BuildTask {
  factory BuildTask.fromJson(Map<String, Object?> map) {
    final StringBuffer errorBuffer = StringBuffer();
    final String? name = stringOfJson(map, 'name', errorBuffer);
    final String? language = stringOfJson(map, 'language', errorBuffer);
    final List<String>? scripts = stringListOfJson(map, 'scripts', errorBuffer);
    final List<String>? parameters = stringListOfJson(
      map, 'parameters', errorBuffer,
    );
    if (name == null ||
        language == null ||
        scripts == null ||
        parameters == null) {
      return BuildTask._invalid(errorBuffer.toString());
    }
    return BuildTask._(name, language, scripts, parameters);
  }

  BuildTask._invalid(this.error) :
    valid = false,
    name = '',
    language = '',
    scripts = <String>[],
    parameters = <String>[];

  BuildTask._(this.name, this.language, this.scripts, this.parameters) :
    valid = true, error = null;

  final bool valid;
  final String? error;
  final String name;
  final String language;
  final List<String> scripts;
  final List<String> parameters;

  String check(String path) {
    if (!valid) {
      return '$path\n${error!}';
    }
    return '';
  }

  @override
  String toString() => toStringIndented(0);

  String toStringIndented(int spaces) {
    final StringBuffer buffer = StringBuffer();
    buffer.write(' '*spaces);
    buffer.write('$name: ');
    buffer.write(language);
    buffer.write(' ');
    for (final String script in scripts) {
      buffer.write(' ');
      buffer.write(script);
    }
    for (final String parameter in parameters) {
      buffer.write(' ');
      buffer.write(parameter);
    }
    return buffer.toString();
  }
}

/// "builds" -> "archives" contains a list of maps with fields like:
/// {
///   "name": "",
///   "base_path": "",
///   "type": "",
///   "include_paths": [""],
///   "realm": ""
/// }
class BuildArchive {
  factory BuildArchive.fromJson(Map<String, Object?> map) {
    final StringBuffer errorBuffer = StringBuffer();
    final String? name = stringOfJson(map, 'name', errorBuffer);
    final String? type = stringOfJson(map, 'type', errorBuffer);
    final String? basePath = stringOfJson(map, 'base_path', errorBuffer);
    final List<String>? includePaths = stringListOfJson(
      map, 'include_paths', errorBuffer,
    );
    if (name == null ||
        type == null ||
        basePath == null ||
        includePaths == null) {
      return BuildArchive._invalid(errorBuffer.toString());
    }
    return BuildArchive._(name, type, basePath, includePaths);
  }

  BuildArchive._invalid(this.error) :
    valid = false,
    name = '',
    type = '',
    basePath = '',
    includePaths = <String>[];

  BuildArchive._(this.name, this.type, this.basePath, this.includePaths) :
    valid = true, error = null;

  final bool valid;
  final String? error;
  final String name;
  final String type;
  final String basePath;
  final List<String> includePaths;

  String check(String path) {
    if (!valid) {
      return '$path\n${error!}';
    }
    return '';
  }
}

/// Global "tests" is a list of maps containing fields like:
/// {
///   "name": "",
///   "recipe": "",
///   "drone_dimensions": [""],
///   "dependencies": [""],
///   "tasks": [] (same format as above)
/// }
class GlobalTest {
  factory GlobalTest.fromJson(Map<String, Object?> map) {
    final StringBuffer errorBuffer = StringBuffer();
    final String? name = stringOfJson(map, 'name', errorBuffer);
    final String? recipe = stringOfJson(map, 'recipe', errorBuffer);
    final List<String>? droneDimensions = stringListOfJson(
      map, 'drone_dimensions', errorBuffer,
    );
    final List<String>? dependencies = stringListOfJson(
      map, 'dependencies', errorBuffer,
    );
    final List<TestTask>? tasks = objListOfJson(
      map, 'tasks', errorBuffer, TestTask.fromJson,
    );
    if (name == null ||
        recipe == null ||
        droneDimensions == null ||
        dependencies == null ||
        tasks == null) {
      return GlobalTest._invalid(errorBuffer.toString());
    }
    return GlobalTest._(name, recipe, droneDimensions, dependencies, tasks);
  }

  GlobalTest._invalid(this.error) :
    valid = false,
    name = '',
    recipe = '',
    droneDimensions = <String>[],
    dependencies = <String>[],
    tasks = <TestTask>[];

  GlobalTest._(
    this.name,
    this.recipe,
    this.droneDimensions,
    this.dependencies,
    this.tasks,
  ) : valid = true, error = null;

  final bool valid;
  final String? error;
  final String name;
  final String recipe;
  final List<String> droneDimensions;
  final List<String> dependencies;
  final List<TestTask> tasks;

  String check(String path) {
    if (!valid) {
      return '$path\n${error!}';
    }
    final StringBuffer errorBuffer = StringBuffer();
    for (int i = 0; i < tasks.length; i++) {
      final TestTask task = tasks[i];
      errorBuffer.write(task.check('$path/tasks[$i]'));
    }
    return errorBuffer.toString();
  }

  @override
  String toString() => toStringIndented(0);

  String toStringIndented(int spaces) {
    final StringBuffer buffer = StringBuffer();
    buffer.write(' '*spaces);
    buffer.writeln(name);
    for (final TestTask task in tasks) {
      buffer.write(' '*spaces);
      buffer.writeln('-> Task "$task"');
    }
    return buffer.toString();
  }
}

/// Task for a global generator and a global test.
/// {
///   "name": "",
///   "parameters": [""],
///   "script": "",
///   "language": ""
/// }
class TestTask {
  factory TestTask.fromJson(Map<String, Object?> map) {
    final StringBuffer errorBuffer = StringBuffer();
    final String? name = stringOfJson(map, 'name', errorBuffer);
    final String? language = stringOfJson(map, 'language', errorBuffer);
    final String? script = stringOfJson(map, 'script', errorBuffer);
    final List<String>? parameters = stringListOfJson(
      map, 'parameters', errorBuffer,
    );
    if (name == null ||
        language == null ||
        script == null ||
        parameters == null) {
      return TestTask._invalid(errorBuffer.toString());
    }
    return TestTask._(name, language, script, parameters);
  }

  TestTask._invalid(this.error) :
    valid = false,
    name = '',
    language = '',
    script = '',
    parameters = <String>[];

  TestTask._(this.name, this.language, this.script, this.parameters) :
    valid = true, error = null;

  final bool valid;
  final String? error;
  final String name;
  final String language;
  final String script;
  final List<String> parameters;

  String check(String path) {
    if (!valid) {
      return '$path\n${error!}';
    }
    return '';
  }

  @override
  String toString() => toStringIndented(0);

  String toStringIndented(int spaces) {
    final StringBuffer buffer = StringBuffer();
    buffer.write('$name: ');
    buffer.write(language);
    buffer.write(' ');
    buffer.write(script);
    for (final String parameter in parameters) {
      buffer.write(' ');
      buffer.write(parameter);
    }
    return buffer.toString();
  }
}

List<T>? objListOfJson<T>(
  Map<String, Object?> map,
  String field,
  StringBuffer errorBuffer,
  T Function(Map<String, Object?>) fn,
) {
  if (map[field] == null) {
    return <T>[];
  }
  if (map[field]! is! List<Object?>) {
    errorBuffer.writeln('"$field" field must be a list.');
    return null;
  }
  for (final Object? obj in map[field]! as List<Object?>) {
    if (obj is! Map<String, Object?>) {
      errorBuffer.writeln('"$field" field must be a map.');
      return null;
    }
  }
  return (map[field]! as List<Object?>)
    .cast<Map<String, Object?>>().map<T>(fn).toList();
}

List<String>? stringListOfJson(
  Map<String, Object?> map,
  String field,
  StringBuffer errorBuffer,
) {
  if (map[field] == null) {
    return <String>[];
  }
  if (map[field]! is! List<Object?>) {
    errorBuffer.writeln('"$field" field must be a list.');
    return null;
  }
  for (final Object? obj in map[field]! as List<Object?>) {
    if (obj is! String) {
      errorBuffer.writeln('"$field" field must be a string.');
      return null;
    }
  }
  return (map[field]! as List<Object?>).cast<String>();
}

String? stringOfJson(
  Map<String, Object?> map,
  String field,
  StringBuffer errorBuffer,
) {
  if (map[field] == null) {
    return '<undef>';
  }
  if (map[field]! is! String) {
    errorBuffer.writeln('"$field" field must be a string.');
    return null;
  }
  return map[field]! as String;
}
