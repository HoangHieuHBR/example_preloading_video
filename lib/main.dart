import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:preload_video_demo/bloc/video_bloc.dart';
import 'package:preload_video_demo/core/const.dart';
import 'core/build_context.dart';
import 'injection.dart' as di;
import 'injection.dart';
import 'services/api_service.dart';
import 'services/navigation_service.dart';
import 'video_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  di.configureInjection(Environment.prod);
  runApp(const MyApp());
}

Future createIsolate(int index) async {
  BlocProvider.of<VideoBloc>(context, listen: false)
      .add(const VideoEvent.setLoading());

  ReceivePort mainReceivePort = ReceivePort();
  Isolate.spawn<SendPort>(getVideosTask, mainReceivePort.sendPort);

  SendPort isolateSendPort = await mainReceivePort.first;

  ReceivePort isolateResponseReceivePort = ReceivePort();

  isolateSendPort.send([index, isolateResponseReceivePort.sendPort]);

  final isolateResponse = await isolateResponseReceivePort.first;
  final urls = isolateResponse;

  // ignore: use_build_context_synchronously
  if (!context.mounted) return;
  BlocProvider.of<VideoBloc>(context, listen: false)
      .add(VideoEvent.updateUrls(urls));
}

void getVideosTask(SendPort sendPort) async {
  ReceivePort isolateReceivePort = ReceivePort();

  sendPort.send(isolateReceivePort.sendPort);

  await for (var message in isolateReceivePort) {
    if (message is List) {
      final int index = message[0];

      final SendPort isolateResponseSendPort = message[1];

      final List<String> urls =
          await ApiService.getVideos(id: index + kPreloadLimit);

      isolateResponseSendPort.send(urls);
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static final NavigationService _navigationService =
      getIt<NavigationService>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<VideoBloc>()..add(const VideoEvent.getVideosFromApi()),
      child: MaterialApp(
        key: _navigationService.navigationKey,
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const VideoPage(),
      ),
    );
  }
}
