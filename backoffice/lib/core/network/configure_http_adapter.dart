import 'package:dio/dio.dart';

import 'configure_http_adapter_stub.dart'
    if (dart.library.js_interop) 'configure_http_adapter_web.dart'
    as platform;

void configureHttpAdapter(Dio dio) => platform.configureHttpAdapter(dio);
