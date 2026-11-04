// Debug-only entrypoint for live inspection via flutter_driver_command
// (dart mcp-server). Reuses the real main() bootstrap untouched; the only
// addition is enabling the driver extension before it runs. Never built into
// a release — store builds use lib/main.dart.
import 'package:flutter_driver/driver_extension.dart';

import 'main.dart' as app;

Future<void> main() async {
  enableFlutterDriverExtension();
  await app.main();
}
