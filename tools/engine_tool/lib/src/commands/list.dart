// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:args/command_runner.dart';
import 'package:platform/platform.dart';

import '../build_config.dart';

class ListCommand extends Command<int> {
  ListCommand({
    required this.outSink,
    required this.errSink,
    required this.platform,
    required this.buildConfigs,
  });

  final StringSink outSink;
  final StringSink errSink;
  final Platform platform;
  final Map<String, BuildConfig> buildConfigs;

  @override
  String get name => 'list';

  @override
  String get description => 'Lists all available build configurations';

  @override
  List<String> get aliases => <String>['l'];

  @override
  int run() {
    final List<String> names = buildConfigs.keys.toList();
    names.sort();
    for (final String config in names) {
      if (platform.operatingSystem == _platformOfConfigName(config)) {
        outSink.writeln(buildConfigs[config]);
      }
    }
    return 0;
  }

  String _platformOfConfigName(String name) {
    if (name.startsWith('mac')) {
      return 'macos';
    }
    return name.substring(0, name.indexOf('_'));
  }
}
