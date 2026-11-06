import '../../domain/entities/prophet_story_section_entity.dart';
import '../../domain/repositories/prophets_stories_repository.dart';
import '../datasources/prophets_stories_remote_data_source.dart';

class ProphetsStoriesRepositoryImpl implements ProphetsStoriesRepository {
  final ProphetsStoriesRemoteDataSource remoteDataSource;

  List<ProphetStorySectionEntity>? _cachedSections;
  final Map<String, String> _cachedContent = {};

  ProphetsStoriesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ProphetStorySectionEntity>> getStorySections() async {
    final cachedSections = _cachedSections;
    if (cachedSections != null) return cachedSections;

    final models = await remoteDataSource.getStorySections();
    _cachedSections = List.unmodifiable(
      models.map((model) => model.toEntity()),
    );
    return _cachedSections!;
  }

  @override
  Future<String> getStoryContent(ProphetStorySectionEntity section) async {
    final key = '${section.pageTitle}#${section.sectionIndex}';
    final cachedContent = _cachedContent[key];
    if (cachedContent != null) return cachedContent;

    final content = await remoteDataSource.getStorySectionContent(
      pageTitle: section.pageTitle,
      sectionIndex: section.sectionIndex,
    );
    _cachedContent[key] = content;
    return content;
  }
}
