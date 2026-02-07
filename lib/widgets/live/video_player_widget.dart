import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String? streamUrl;
  final String? replayUrl;
  final String? thumbnailUrl;
  final bool isLive;

  const VideoPlayerWidget({
    Key? key,
    this.streamUrl,
    this.replayUrl,
    this.thumbnailUrl,
    required this.isLive,
  }) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;

  bool _isBuffering = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    final url = widget.isLive ? widget.streamUrl : widget.replayUrl;
    if (url == null) return;

    _controller = VideoPlayerController.networkUrl(Uri.parse(url));
    try {
      await _controller!.initialize();
      if (widget.isLive) {
        _controller!.play();
      }
      _controller!.addListener(_videoListener);
      setState(() {});
    } catch (e) {
      debugPrint('Video initialization failed: $e');
    }
  }

  void _videoListener() {
    if (_controller!.value.isBuffering != _isBuffering) {
      setState(() {
        _isBuffering = _controller!.value.isBuffering;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      if (widget.thumbnailUrl != null) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              widget.thumbnailUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.black),
            ),
            Container(color: Colors.black.withOpacity(0.5)),
            const Center(child: CircularProgressIndicator(color: Colors.white)),
          ],
        );
      }
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Stack(
      children: [
        Center(
          child: AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          ),
        ),
        if (!_controller!.value.isPlaying && !_isBuffering)
          Center(
            child: IconButton(
              iconSize: 64,
              icon: const Icon(Icons.play_circle_fill, color: Colors.white70),
              onPressed: () {
                setState(() {
                  _controller!.play();
                });
              },
            ),
          ),
        if (_isBuffering)
          const Center(child: CircularProgressIndicator(color: Colors.white)),
        // Contrôles overlay - simplified
        _buildControls(),
      ],
    );
  }

  Widget _buildControls() {
    return Positioned(
      bottom: 20,
      left: 20,
      child: IconButton(
        icon: Icon(
          _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 30,
        ),
        onPressed: () {
          setState(() {
            if (_controller!.value.isPlaying) {
              _controller!.pause();
            } else {
              _controller!.play();
            }
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
