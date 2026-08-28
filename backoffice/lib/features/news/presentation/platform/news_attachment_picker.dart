import 'news_attachment_picker_stub.dart'
    if (dart.library.js_interop) 'news_attachment_picker_web.dart'
    as platform;
import 'news_attachment_picker_types.dart';

export 'news_attachment_picker_types.dart';

Future<PickedNewsAttachment?> pickNewsAttachment() =>
    platform.pickNewsAttachment();
