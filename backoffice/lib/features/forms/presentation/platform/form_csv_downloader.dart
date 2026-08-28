import 'form_csv_downloader_stub.dart'
    if (dart.library.js_interop) 'form_csv_downloader_web.dart'
    as platform;

bool downloadFormCsv({required String filename, required String csv}) =>
    platform.downloadFormCsv(filename: filename, csv: csv);
