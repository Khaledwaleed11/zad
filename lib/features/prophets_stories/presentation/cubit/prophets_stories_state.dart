import 'package:equatable/equatable.dart';

import '../../domain/entities/prophet_story_section_entity.dart';

enum ProphetStoriesStatus { initial, loading, success, failure }

enum ProphetStoryContentStatus { initial, loading, success, failure }

class ProphetsStoriesState extends Equatable {
  final ProphetStoriesStatus status;
  final List<ProphetStorySectionEntity> sections;
  final String? errorMessage;
  final ProphetStorySectionEntity? selectedSection;
  final ProphetStoryContentStatus contentStatus;
  final String? content;
  final String? contentErrorMessage;

  const ProphetsStoriesState({
    this.status = ProphetStoriesStatus.initial,
    this.sections = const [],
    this.errorMessage,
    this.selectedSection,
    this.contentStatus = ProphetStoryContentStatus.initial,
    this.content,
    this.contentErrorMessage,
  });

  ProphetsStoriesState copyWith({
    ProphetStoriesStatus? status,
    List<ProphetStorySectionEntity>? sections,
    String? errorMessage,
    bool clearErrorMessage = false,
    ProphetStorySectionEntity? selectedSection,
    bool clearSelectedSection = false,
    ProphetStoryContentStatus? contentStatus,
    String? content,
    bool clearContent = false,
    String? contentErrorMessage,
    bool clearContentErrorMessage = false,
  }) {
    return ProphetsStoriesState(
      status: status ?? this.status,
      sections: sections ?? this.sections,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      selectedSection: clearSelectedSection
          ? null
          : selectedSection ?? this.selectedSection,
      contentStatus: contentStatus ?? this.contentStatus,
      content: clearContent ? null : content ?? this.content,
      contentErrorMessage: clearContentErrorMessage
          ? null
          : contentErrorMessage ?? this.contentErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    sections,
    errorMessage,
    selectedSection,
    contentStatus,
    content,
    contentErrorMessage,
  ];
}
