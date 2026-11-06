import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/prophet_story_section_entity.dart';
import '../../domain/usecases/get_prophet_story_content.dart';
import '../../domain/usecases/get_prophet_story_sections.dart';
import 'prophets_stories_state.dart';

class ProphetsStoriesCubit extends Cubit<ProphetsStoriesState> {
  final GetProphetStorySections getStorySections;
  final GetProphetStoryContent getStoryContent;

  ProphetsStoriesCubit({
    required this.getStorySections,
    required this.getStoryContent,
  }) : super(const ProphetsStoriesState());

  Future<void> loadSections({bool forceRefresh = false}) async {
    if (state.status == ProphetStoriesStatus.loading) return;
    if (!forceRefresh && state.status == ProphetStoriesStatus.success) return;

    emit(
      state.copyWith(
        status: ProphetStoriesStatus.loading,
        clearErrorMessage: true,
      ),
    );

    try {
      final sections = await getStorySections();
      emit(
        state.copyWith(
          status: ProphetStoriesStatus.success,
          sections: sections,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ProphetStoriesStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> loadStoryContent(ProphetStorySectionEntity section) async {
    emit(
      state.copyWith(
        selectedSection: section,
        contentStatus: ProphetStoryContentStatus.loading,
        clearContent: true,
        clearContentErrorMessage: true,
      ),
    );

    try {
      final content = await getStoryContent(section);
      if (state.selectedSection?.sectionIndex != section.sectionIndex ||
          state.selectedSection?.pageTitle != section.pageTitle) {
        return;
      }

      emit(
        state.copyWith(
          contentStatus: ProphetStoryContentStatus.success,
          content: content,
        ),
      );
    } catch (error) {
      if (state.selectedSection?.sectionIndex != section.sectionIndex ||
          state.selectedSection?.pageTitle != section.pageTitle) {
        return;
      }

      emit(
        state.copyWith(
          contentStatus: ProphetStoryContentStatus.failure,
          contentErrorMessage: error.toString(),
        ),
      );
    }
  }

  void clearStoryContent() {
    emit(
      state.copyWith(
        clearSelectedSection: true,
        contentStatus: ProphetStoryContentStatus.initial,
        clearContent: true,
        clearContentErrorMessage: true,
      ),
    );
  }
}
