import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:preload_video_demo/core/const.dart';
import 'package:preload_video_demo/services/api_service.dart';
import 'package:video_player/video_player.dart';
import 'package:injectable/injectable.dart';

import '../main.dart';

part 'video_event.dart';
part 'video_state.dart';
part 'video_bloc.freezed.dart';

@injectable
@prod
class VideoBloc extends Bloc<VideoEvent, VideoState> {
  VideoBloc() : super(VideoState.initial()) {
    on(_mapEventToState);
  }

  void _mapEventToState(VideoEvent event, Emitter<VideoState> emit) async {
    await event.map(
      getVideosFromApi: (e) async {
        final List<String> urls = await ApiService.getVideos();
        state.urls.addAll(urls);

        await _initializeControllerAtIndex(0);

        _playControllerAtIndex(0);

        await _initializeControllerAtIndex(1);

        emit(state.copyWith(reloadCounter: state.reloadCounter + 1));
      },
      setLoading: (_) {
        emit(state.copyWith(isLoading: true));
      },
      updateUrls: (e) {
        state.urls.addAll(e.urls);

        _initializeControllerAtIndex(state.focusedIndex + 1);

        emit(state.copyWith(
          reloadCounter: state.reloadCounter + 1,
          isLoading: false,
        ));
        log('🚀🚀🚀 NEW VIDEOS ADDED');
      },
      onVideoIndexChanged: (e) {
        final bool shouldFetch = (e.index + kPreloadLimit) % kNextLimit == 0 &&
            state.urls.length == e.index + kPreloadLimit;

        log("Fetch: $shouldFetch");

        if (shouldFetch) {
          createIsolate(e.index);
        }

        if (e.index > state.focusedIndex) {
          _playNext(e.index);
        } else {
          _playPrevious(e.index);
        }

        emit(state.copyWith(focusedIndex: e.index));
      },
    );
  }

  Future _initializeControllerAtIndex(int index) async {
    if (state.urls.length > index && index >= 0) {
      final VideoPlayerController controller =
          VideoPlayerController.networkUrl(Uri.parse(state.urls[index]));

      state.controllers[index] = controller;

      await controller.initialize();

      log('🚀🚀🚀 INITIALIZED $index');
    }
  }

  void _playControllerAtIndex(int index) {
    if (state.urls.length > index && index >= 0) {
      final VideoPlayerController controller = state.controllers[index]!;

      controller.play().then((value) => controller.setVolume(1));

      controller.setLooping(true);

      log('🚀🚀🚀 PLAYING $index');
    }
  }

  void _stopControllerAtIndex(int index) {
    if (state.urls.length > index && index >= 0) {
      final VideoPlayerController controller = state.controllers[index]!;

      controller.pause();

      controller.seekTo(const Duration());

      log('🚀🚀🚀 STOPPED $index');
    }
  }

  void _disposeControllerAtIndex(int index) {
    if (state.urls.length > index && index >= 0) {
      final VideoPlayerController? controller = state.controllers[index];

      controller?.dispose();

      if (controller != null) {
        state.controllers.remove(controller);
      }

      log('🚀🚀🚀 DISPOSED $index');
    }
  }

  void _playNext(int index) {
    _stopControllerAtIndex(index - 1);

    _disposeControllerAtIndex(index - 2);

    _playControllerAtIndex(index);

    _initializeControllerAtIndex(index + 1);
  }

  void _playPrevious(int index) {
    _stopControllerAtIndex(index + 1);

    _disposeControllerAtIndex(index + 2);

    _playControllerAtIndex(index);

    _initializeControllerAtIndex(index - 1);
  }
}
