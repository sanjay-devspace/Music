class LanguageModel {
  const LanguageModel({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.searchTerms,
    this.emoji,
    this.isPopular = false,
  });

  final String code;
  final String name;
  final String nativeName;
  final List<String> searchTerms;
  final String? emoji;
  final bool isPopular;
}
