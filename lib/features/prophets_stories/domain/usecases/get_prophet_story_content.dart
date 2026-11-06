import '../entities/prophet_story_section_entity.dart';
import '../repositories/prophets_stories_repository.dart';

class GetProphetStoryContent {
  final ProphetsStoriesRepository repository;

  const GetProphetStoryContent(this.repository);

  Future<String> call(ProphetStorySectionEntity section) {
    return repository.getStoryContent(section);
  }
}
