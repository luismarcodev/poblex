import 'package:dio/dio.dart';

void configureHttpAdapter(Dio dio) {
  // The default IO adapter is correct for VM widget tests. The backoffice
  // itself runs on web and selects the credential-aware adapter instead.
}
