part of 'video_bloc.dart';

@Freezed(makeCollectionsUnmodifiable: false)
class VideoState with _$VideoState {
  factory VideoState({
    required List<String> urls,
    required Map<int, VideoPlayerController> controllers,
    required int focusedIndex,
    required int reloadCounter,
    required bool isLoading,
  }) = _VideoState;

  factory VideoState.initial() => VideoState(
        focusedIndex: 0,
        reloadCounter: 0,
        isLoading: false,
        urls: [],
        controllers: {},
      );
}
