import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:preload_video_demo/bloc/video_bloc.dart';
import 'package:video_player/video_player.dart';

class VideoPage extends StatelessWidget {
  const VideoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<VideoBloc, VideoState>(
        builder: (context, state) {
          return PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: state.urls.length,
            onPageChanged: (index) =>
                BlocProvider.of<VideoBloc>(context, listen: false)
                    .add(VideoEvent.onVideoIndexChanged(index)),
            itemBuilder: (context, index) {
              final bool isLoading =
                  (state.isLoading && index == state.urls.length - 1);

              return state.focusedIndex == index
                  ? VideoWidget(
                      isLoading: isLoading,
                      controller: state.controllers[index]!,
                    )
                  : const SizedBox();
            },
          );
        },
      ),
    );
  }
}

class VideoWidget extends StatelessWidget {
  const VideoWidget({
    super.key,
    required this.isLoading,
    required this.controller,
  });

  final bool isLoading;
  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: VideoPlayer(controller),
        ),
        AnimatedCrossFade(
          alignment: Alignment.bottomCenter,
          sizeCurve: Curves.decelerate,
          duration: const Duration(milliseconds: 400),
          firstChild: const Padding(
            padding: EdgeInsets.all(10.0),
            child: CupertinoActivityIndicator(
              color: Colors.white,
              radius: 8,
            ),
          ),
          secondChild: const SizedBox(),
          crossFadeState:
              isLoading ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        ),
      ],
    );
  }
}
