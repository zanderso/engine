// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:platform/platform.dart';

import 'build_config.dart';
import 'commands/list.dart';

class EngineToolRunner {
  EngineToolRunner({
    required this.outSink,
    required this.errSink,
    required this.platform,
    required this.buildConfigs,
  }) {
    _initCommandRunner();
  }

  final StringSink outSink;
  final StringSink errSink;
  final Platform platform;
  final Map<String, BuildConfig> buildConfigs;
  final CommandRunner<int> _commandRunner = CommandRunner<int>(
    'engine_tool', 'A command line tool for working in the Engine repo.',
  );

  Future<int?> start(List<String> args) {
    return _commandRunner.run(args);
  }

  void _initCommandRunner() {
    _commandRunner.addCommand(ListCommand(
      outSink: outSink,
      errSink: errSink,
      platform: platform,
      buildConfigs: buildConfigs,
    ));
  }
}
