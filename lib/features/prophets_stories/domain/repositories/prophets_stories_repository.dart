import '../entities/prophet_story_section_entity.dart';

abstract class ProphetsStoriesRepository {
  Future<List<ProphetStorySectionEntity>> getStorySections();

  Future<String> getStoryContent(ProphetStorySectionEntity section);
}
