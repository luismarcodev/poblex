import 'survey_csv_downloader_stub.dart'
    if (dart.library.js_interop) 'survey_csv_downloader_web.dart'
    as platform;

bool downloadSurveyCsv({required String filename, required String csv}) =>
    platform.downloadSurveyCsv(filename: filename, csv: csv);
