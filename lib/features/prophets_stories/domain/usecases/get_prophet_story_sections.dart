import '../entities/prophet_story_section_entity.dart';
import '../repositories/prophets_stories_repository.dart';

class GetProphetStorySections {
  final ProphetsStoriesRepository repository;

  const GetProphetStorySections(this.repository);

  Future<List<ProphetStorySectionEntity>> call() {
    return repository.getStorySections();
  }
}
