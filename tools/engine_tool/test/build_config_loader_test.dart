// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert' as convert;

import 'package:engine_tool/src/build_config.dart';
import 'package:engine_tool/src/build_config_loader.dart';
import 'package:file/file.dart';
import 'package:file/memory.dart';
import 'package:litetest/litetest.dart';

const String buildConfigJson = '''
{
  "builds": [
    {
      "archives": [
        {
          "name": "build_name",
          "base_path": "base/path",
          "type": "gcs",
          "include_paths": ["include/path"],
          "realm": "archive_realm"
        }
      ],
      "drone_dimensions": ["dimension"],
      "gclient_variables": {
        "variable": false
      },
      "gn": ["--gn-arg"],
      "name": "build_name",
      "ninja": {
        "config": "build_name",
        "targets": ["ninja_target"]
      },
      "tests": [
        {
          "language": "python3",
          "name": "build_name tests",
          "parameters": ["--test-params"],
          "script": "test/script.py",
          "contexts": ["context"]
        }
      ],
      "generators": {
        "tasks": [
          {
            "name": "generator_task",
            "parameters": ["--gen-param"],
            "scripts": ["gen/script.py"]
          }
        ]
      }
    }
  ],
  "generators": {
    "tasks": [
      {
        "name": "global generator task",
        "parameters": ["--global-gen-param"],
        "script": "global/gen_script.dart",
        "language": "dart"
      }
    ]
  },
  "tests": [
    {
      "name": "global test",
      "recipe": "engine_v2/tester_engine",
      "drone_dimensions": ["dimension"],
      "gclient_variables": {
        "variable": false
      },
      "dependencies": ["dependency"],
      "test_dependencies": [
        {
          "dependency": "test_dependency",
          "version": "git_revision:3a77d0b12c697a840ca0c7705208e8622dc94603"
        }
      ],
      "tasks": [
        {
          "name": "global test task",
          "parameters": ["--test-parameter"],
          "script": "global/test/script.py"
        }
      ]
    }
  ]
}
''';

int main() {
  test('BuildConfigLoader can load a build config', () {
    final FileSystem fs = MemoryFileSystem();
    final String buildConfigPath = fs.path.join(
      'flutter', 'ci', 'builders', 'linux_test_build.json',
    );
    final File buildConfigFile = fs.file(buildConfigPath);
    buildConfigFile.create(recursive: true);
    buildConfigFile.writeAsStringSync(buildConfigJson);

    final StringBuffer outSink = StringBuffer();
    final StringBuffer errSink = StringBuffer();
    final BuildConfigLoader loader = BuildConfigLoader(
      outSink: outSink, errSink: errSink, fs: fs,
    );

    expect(loader.configs, isNotNull);
    expect(loader.configs!['linux_test_build'], isNotNull);
  });

  test('BuildConfigLoader gives a null config when no configs found', () {
    final FileSystem fs = MemoryFileSystem();
    final StringBuffer outSink = StringBuffer();
    final StringBuffer errSink = StringBuffer();
    final BuildConfigLoader loader = BuildConfigLoader(
      outSink: outSink, errSink: errSink, fs: fs,
    );

    expect(loader.configs, isNull);
  });
  return 0;
}
