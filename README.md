# preload_video_demo

### Introduction 🚀

> Preloading logic to reduce video initialization using isolate to fetch videos in the background so that the video experience is not disturbed.

> Without the use of isolate, the video will be paused whenever there is an API call because the main thread will be busy fetching new video URLs.

> More about isolate: 🌐 https://blog.codemagic.io/understanding-flutter-isolates/

> isolate information with Vietnamese: 🌐 https://viblo.asia/p/da-luong-trong-flutter-su-dung-isolate-Qbq5QRNJKD8

### Logic 🎯

![lib](images/logic.png)