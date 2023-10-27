import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:preload_video_demo/bloc/video_bloc.dart';
import 'package:video_player/video_player.dart';

enum ScrollAction {
  up,
  down,
  none,
}

class VideoPage extends StatelessWidget {
  const VideoPage({super.key});

  static ScrollAction scrollAction = ScrollAction.none;

  static ScrollAction getScrollAction(ScrollUpdateNotification notification) {
    if (notification.scrollDelta! > 0) {
      return ScrollAction.down;
    } else if (notification.scrollDelta! < 0) {
      return ScrollAction.up;
    } else {
      return ScrollAction.none;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<VideoBloc, VideoState>(
        builder: (context, state) {
          return NotificationListener<ScrollUpdateNotification>(
            onNotification: (notification) {
              scrollAction = getScrollAction(notification);
              return false;
            },
            child: PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: state.urls.length,
              onPageChanged: (index) =>
                  BlocProvider.of<VideoBloc>(context, listen: false)
                      .add(VideoEvent.onVideoIndexChanged(index)),
              itemBuilder: (context, index) {
                final bool isLoading =
                    (state.isLoading && index == state.urls.length - 1);

                log("current index: $index");
                log("focused index: ${state.focusedIndex}");

                return state.focusedIndex == index
                    ? VideoWidget(
                        isLoading: isLoading,
                        controller: state.controllers[index]!,
                      )
                    : (scrollAction == ScrollAction.down)
                        ? VideoWidget(
                            isLoading: isLoading,
                            controller:
                                state.controllers[state.focusedIndex + 1] ??
                                    state.controllers[index]!,
                          )
                        : (scrollAction == ScrollAction.up)
                            ? VideoWidget(
                                isLoading: isLoading,
                                controller:
                                    state.controllers[state.focusedIndex - 1] ??
                                        state.controllers[index]!,
                              )
                            : const SizedBox.shrink();
              },
            ),
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
