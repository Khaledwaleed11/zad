
class HadithSearchResultEntity {
  final String citation;
  final int? number;
  final int seq;
  final String text;
  final String api;
  final String link;

  const HadithSearchResultEntity({
    required this.citation,
    required this.number,
    required this.seq,
    required this.text,
    required this.api,
    required this.link,
  });
}
