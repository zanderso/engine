// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:platform/platform.dart';

import 'src/build_config_loader.dart';
import 'src/engine_tool_runner.dart';

Future<int?> run(
  StringSink outSink,
  StringSink errSink,
  List<String> args,
) async {
  const FileSystem fs = LocalFileSystem();
  final BuildConfigLoader loader = BuildConfigLoader(
    outSink: outSink,
    errSink: errSink,
    fs: fs,
  );
  if (loader.configs == null) {
    errSink.writeln(
      'Could not find build configs relative to "${fs.currentDirectory}" or '
      'any of its parent directories',
    );
    return 1;
  }

  final EngineToolRunner engineTool = EngineToolRunner(
    outSink: outSink,
    errSink: errSink,
    platform: const LocalPlatform(),
    buildConfigs: loader.configs!,
  );

  return engineTool.start(args);
}
