import 'business_photo_picker_stub.dart'
    if (dart.library.js_interop) 'business_photo_picker_web.dart'
    as platform;
import 'business_photo_picker_types.dart';

export 'business_photo_picker_types.dart';

Future<List<PickedBusinessPhoto>> pickBusinessPhotos() =>
    platform.pickBusinessPhotos();
