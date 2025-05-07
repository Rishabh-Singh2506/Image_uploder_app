import 'dart:io' show File;
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<File> _selectedImageFiles = [];
  List<Uint8List> _webImages = [];

  List<File> _selectedVideoFiles = [];
  List<Uint8List> _webVideos = [];

  bool _viewImages = true;
  bool _viewVideos = false;

  // State for showing full-screen media in a container
  int? _clickedIndex;
  bool _isImage = false;

  // Picking images
  Future<void> _pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: kIsWeb,
    );

    if (result != null) {
      setState(() {
        if (kIsWeb) {
          _webImages.addAll(result.files.map((file) => file.bytes!).toList());
        } else {
          _selectedImageFiles
              .addAll(result.paths.map((path) => File(path!)).toList());
        }
      });
    }
  }

  // Picking videos
  Future<void> _pickVideos() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: true,
      withData: kIsWeb,
    );

    if (result != null) {
      setState(() {
        if (kIsWeb) {
          _webVideos.addAll(result.files.map((file) => file.bytes!).toList());
        } else {
          _selectedVideoFiles
              .addAll(result.paths.map((path) => File(path!)).toList());
        }
      });
    }
  }

  // Show Image in a 500x500 container
  void _showFullScreenImage(int index) {
    setState(() {
      _clickedIndex = index;
      _isImage = true;
    });
  }

  // Show Video in a 500x500 container
  void _showFullScreenVideo(int index) {
    setState(() {
      _clickedIndex = index;
      _isImage = false;
    });
  }

  // Media Widgets
  List<Widget> _buildMediaWidgets(double maxWidth) {
    double mediaWidth = 150.0;
    double spacing = 16.0;

    int columns = (maxWidth / (mediaWidth + spacing)).floor();
    columns = columns > 6 ? 6 : columns;

    final List<Widget> widgets = [];

    // Display Images
    for (int i = 0; i < (kIsWeb ? _webImages.length : _selectedImageFiles.length); i++) {
      Widget imageWidget = kIsWeb
          ? Image.memory(_webImages[i], width: mediaWidth, height: mediaWidth, fit: BoxFit.cover)
          : Image.file(_selectedImageFiles[i], width: mediaWidth, height: mediaWidth, fit: BoxFit.cover);

      widgets.add(Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => _showFullScreenImage(i),
            child: Container(
              width: mediaWidth,
              height: mediaWidth,
              decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
              child: imageWidget,
            ),
          ),
          SizedBox(height: 4),
          ElevatedButton(
            onPressed: () {
              setState(() {
                if (kIsWeb) {
                  _webImages.removeAt(i);
                } else {
                  _selectedImageFiles.removeAt(i);
                }
              });
            },
            child: Text("Delete"),
          ),
        ],
      ));
    }

    // Display Videos
    for (int i = 0; i < (kIsWeb ? _webVideos.length : _selectedVideoFiles.length); i++) {
      Widget videoWidget;

      if (kIsWeb) {
        videoWidget = Icon(Icons.videocam, size: 60, color: Colors.grey);
      } else {
        videoWidget = _VideoThumbnailPlayer(file: _selectedVideoFiles[i]);
      }

      widgets.add(Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => _showFullScreenVideo(i),
            child: Container(
              width: mediaWidth,
              height: mediaWidth,
              decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
              child: Center(child: videoWidget),
            ),
          ),
          SizedBox(height: 4),
          ElevatedButton(
            onPressed: () {
              setState(() {
                if (kIsWeb) {
                  _webVideos.removeAt(i);
                } else {
                  _selectedVideoFiles.removeAt(i);
                }
              });
            },
            child: Text("Delete"),
          ),
        ],
      ));
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multi-Image/Video Picker',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Upload Media'),
        ),
        body: SingleChildScrollView(  // Wrap the whole body in SingleChildScrollView to enable scrolling
          child: Column(
            children: [
              Container(
                width: double.infinity,
                color: Colors.cyanAccent,
                padding: EdgeInsets.all(12),
                child: Text(
                  'Photo uploader - a creation by Rishabh Singh',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Calibri',
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: [
                  ElevatedButton(
                    onPressed: _pickImages,
                    child: Text('Select Images'),
                  ),
                  ElevatedButton(
                    onPressed: _pickVideos,
                    child: Text('Select Videos'),
                  ),
                ],
              ),
              SizedBox(height: 10),
              LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(  // Make media gallery scrollable
                    padding: EdgeInsets.all(8),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: _buildMediaWidgets(constraints.maxWidth),
                    ),
                  );
                },
              ),
              // Show Fullscreen Image or Video in 500x500 Container
              if (_clickedIndex != null)
                Container(
                  width: 500,
                  height: 500,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                  padding: EdgeInsets.all(10),
                  child: _isImage
                      ? GestureDetector(
                    onTap: () {
                      setState(() {
                        _clickedIndex = null;
                      });
                    },
                    child: kIsWeb
                        ? Image.memory(
                      _webImages[_clickedIndex!],
                      fit: BoxFit.cover,
                    )
                        : Image.file(
                      _selectedImageFiles[_clickedIndex!],
                      fit: BoxFit.cover,
                    ),
                  )
                      : GestureDetector(
                    onTap: () {
                      setState(() {
                        _clickedIndex = null;
                      });
                    },
                    child: _VideoThumbnailPlayer(
                        file: _selectedVideoFiles[_clickedIndex!]),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoThumbnailPlayer extends StatefulWidget {
  final File file;
  const _VideoThumbnailPlayer({required this.file});

  @override
  State<_VideoThumbnailPlayer> createState() => _VideoThumbnailPlayerState();
}

class _VideoThumbnailPlayerState extends State<_VideoThumbnailPlayer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    _controller = VideoPlayerController.file(widget.file)
      ..initialize().then((_) {
        setState(() {});
        _controller.setLooping(true);
        _controller.setVolume(0);
        _controller.play();
      });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: VideoPlayer(_controller),
    )
        : CircularProgressIndicator();
  }
}
