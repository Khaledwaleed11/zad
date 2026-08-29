class AzkarModel {
  final int id;
  final String category;
  final String title;
  final String text;
  final int count;

  const AzkarModel({
    required this.id,
    required this.category,
    required this.title,
    required this.text,
    required this.count,
  });

  factory AzkarModel.fromJson(Map<String, dynamic> json) {
    return AzkarModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      category: json['category']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      count: int.tryParse(json['count']?.toString() ?? '') ?? 1,
    );
  }
}
