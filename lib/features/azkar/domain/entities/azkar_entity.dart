class AzkarEntity {
  final int id;
  final String category;
  final String title;
  final String text;
  final int count;
  final bool isCustom;

  const AzkarEntity({
    required this.id,
    required this.category,
    required this.title,
    required this.text,
    required this.count,
    this.isCustom = false,
  });
}