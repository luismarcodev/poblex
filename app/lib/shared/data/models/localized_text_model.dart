/// Wire shape of a bilingual `{es, va}` field, shared by every feature whose
/// content the backend serves bilingual: news, events, alerts, surveys,
/// forms. The server always sends both languages and lets the client
/// resolve which to show — see `LocalizedText.resolve` in the domain layer.
class LocalizedTextModel {
  const LocalizedTextModel({this.es, this.va});

  final String? es;
  final String? va;

  factory LocalizedTextModel.fromJson(Map<String, dynamic> json) =>
      LocalizedTextModel(es: json['es'] as String?, va: json['va'] as String?);
}
