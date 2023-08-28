// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert' as convert;

import 'package:file/file.dart';
import 'package:meta/meta.dart';

import 'build_config.dart';

class BuildConfigLoader {
  BuildConfigLoader({
    required this.outSink,
    required this.errSink,
    required this.fs,
  });

  final StringSink outSink;
  final StringSink errSink;
  final FileSystem fs;

  late final Map<String, BuildConfig>? configs = (){
    return parseAllBuildConfigs(findBuildConfigs());
  }();

  @visibleForTesting
  Directory? findBuildConfigs() {
    Directory dir = fs.currentDirectory;
    while (true) {
      final Directory buildConfigsDir = dir
        .childDirectory('flutter')
        .childDirectory('ci')
        .childDirectory('builders');
      if (buildConfigsDir.existsSync()) {
        return buildConfigsDir;
      }
      if (fs.identicalSync(dir.path, dir.parent.path)) {
        return null;
      }
      dir = dir.parent;
    }
  }

  @visibleForTesting
  Map<String, BuildConfig>? parseAllBuildConfigs(Directory? dir) {
    if (dir == null) {
      return null;
    }
    final Map<String, BuildConfig> result = <String, BuildConfig>{};
    final List<File> jsonFiles = dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((File f) => f.path.endsWith('.json'))
      .toList();
    for (final File jsonFile in jsonFiles) {
      final String name = jsonFile.basename.substring(
        0, jsonFile.basename.length - 5,
      );
      final String jsonData = jsonFile.readAsStringSync();
      late final dynamic maybeJson;
      try {
        maybeJson = convert.jsonDecode(jsonData);
      } on FormatException catch (e) {
        errSink.writeln('While parsing ${jsonFile.path}:\n$e');
        continue;
      }
      if (maybeJson is! Map<String, Object?>) {
        continue;
      }
      final BuildConfig buildConfig = BuildConfig.fromJson(name, maybeJson);
      final String buildConfigCheck = buildConfig.check(name);
      if (buildConfigCheck.isNotEmpty) {
        errSink.writeln('While loading ${jsonFile.path}:\n$buildConfigCheck');
        continue;
      }
      result[name] = buildConfig;
    }
    return result;
  }
}
