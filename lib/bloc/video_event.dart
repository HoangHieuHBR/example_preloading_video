part of 'video_bloc.dart';

@freezed
class VideoEvent with _$VideoEvent {
  const factory VideoEvent.getVideosFromApi() = _GetVideosFromApi;
  const factory VideoEvent.setLoading() = _SetLoading;
  const factory VideoEvent.updateUrls(List<String> urls) = _UpdateUrls;
  const factory VideoEvent.onVideoIndexChanged(int index) =
      _OnVideoIndexChanged;
}
