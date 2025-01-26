import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:livekit_client/livekit_client.dart' as livekit;
import 'package:livekit_client/livekit_client.dart';
import 'package:socieaty/core/constants.dart';
import 'package:socieaty/core/utils/custom_extension.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/features/livestream/model/livestream_comment.dart';
import 'package:socieaty/features/livestream/model/livestream_likes.dart';
import 'package:socieaty/features/livestream/view/live_disconnected_view.dart';
import 'package:socieaty/features/livestream/view/live_ended_view.dart';
import 'package:socieaty/features/livestream/view/livestream_comments_view.dart';
import 'package:socieaty/features/livestream/viewmodel/live_screen_view_model.dart';
import 'package:socieaty/shared/view_state.dart';
import 'package:socieaty/shared/widgets/loading_indicator.dart';

class LiveScreenArgs {
  final String accessToken;
  final CameraPosition cameraPosition;
  const LiveScreenArgs({
    required this.accessToken,
    required this.cameraPosition,
  });
}

class LiveScreen extends ConsumerStatefulWidget {
  final LiveScreenArgs args;
  const LiveScreen({
    super.key,
    required this.args,
  });

  @override
  ConsumerState<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends ConsumerState<LiveScreen> {
  late EventsListener _roomListener;
  LocalVideoTrack? _localVideoTrack;
  LocalAudioTrack? _localAudioTrack;
  bool _isVideoTrackLoading = false;
  CameraPosition? _cameraPosition;
  Room? _room;

  final List<LivestreamComment> _comments = [];
  int _totalParticipants = 0;
  late LivestreamLikes _roomLikes;

  bool _isDisconnected = false;
  bool _isRoomClosed = false;
  bool _isFinished = false;
  bool _isResourceCleared = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _isVideoTrackLoading = true;
    });

    _cameraPosition = widget.args.cameraPosition;
    _createRoom();
    _roomLikes = LivestreamLikes(roomName: '', likes: 0);
  }

  @override
  void dispose() {
    (() async {
      await _roomListener.dispose();
      try {
        if (_room?.connectionState == livekit.ConnectionState.connected) {
          await _room?.disconnect();
        }
      } catch (error) {
        if (mounted) {
          showSnackbar(context, error.toString(), isError: true);
        }
      }
      await _room?.dispose();
    })();
    super.dispose();
  }

  _createRoom() async {
    _room = Room(
      roomOptions: RoomOptions(
        dynacast: true,
        adaptiveStream: true,
      ),
    );
    final url = AppConstants.livestreamServerUrl;
    await _room!.connect(
      url,
      widget.args.accessToken,
    );
    _room?.addListener(_onChange);
    _setupListener();
    _publishMedia();
    _roomLikes = LivestreamLikes(roomName: _room!.name!, likes: 0);
  }

  _setupListener() {
    _roomListener = _room!.createListener();

    _roomListener
      ..on<RoomDisconnectedEvent>((event) {
        debugPrint("disconnected");
        if (!_isFinished) {
          if (event.reason != null) {
            _isDisconnected = false;
            _isRoomClosed = false;

            if (event.reason == DisconnectReason.disconnected) {
              _isDisconnected = true;
            } else if (event.reason == DisconnectReason.roomDeleted) {
              _isRoomClosed = true;
            }
          }
          if (mounted) {
            setState(() {});
          }
        }
      })
      ..on<DataReceivedEvent>((event) {
        final decodedData = utf8.decode(event.data);
        final Map<String, dynamic> dataJson = jsonDecode(decodedData);
        if (event.topic == 'like') {
          _roomLikes = LivestreamLikes.fromJson(dataJson);
        } else if (event.topic == 'comment') {
          final comment = LivestreamComment.fromJson(dataJson);
          _comments.insert(0, comment);
        }
        if (mounted) {
          setState(() {});
        }
      });
  }

  _onChange() {
    if (_room != null) {
      if (mounted) {
        _totalParticipants = _room!.remoteParticipants.length;
        setState(() {});
      }
    }
  }

  _publishMedia() async {
    _publishCamera();
    try {
      await _room!.localParticipant?.setMicrophoneEnabled(true);
      _localAudioTrack = _room!.localParticipant?.audioTrackPublications.firstOrNull?.track;
    } catch (error) {
      if (mounted) {
        showSnackbar(context, "error: $error");
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  _publishCamera() async {
    setState(() {
      _isVideoTrackLoading = true;
    });
    try {
      await _room!.localParticipant?.setCameraEnabled(true);
      _localVideoTrack = _room!.localParticipant?.videoTrackPublications.firstOrNull?.track;
      debugPrint("_localVideoTrack: ${_localVideoTrack == null}");
      await _localVideoTrack?.setCameraPosition(_cameraPosition!);
    } catch (error) {
      if (mounted) {
        showSnackbar(context, "error: $error");
      }
    } finally {
      _isVideoTrackLoading = false;
      setState(() {});
    }
  }

  _unpublishCamera() async {
    setState(() {
      _isVideoTrackLoading = true;
    });
    try {
      await _room!.localParticipant?.setCameraEnabled(false);
      _localVideoTrack = null;
    } catch (error) {
      if (mounted) {
        showSnackbar(context, "error: $error");
      }
    } finally {
      _isVideoTrackLoading = false;
      setState(() {});
    }
  }

  _toggleCameraEnabledState() async {
    if (_localVideoTrack != null) {
      await _unpublishCamera();
    } else {
      await _publishCamera();
    }
  }

  _toggleCameraPosition() async {
    _cameraPosition = _cameraPosition == CameraPosition.front ? CameraPosition.back : CameraPosition.front;
    await _localVideoTrack?.setCameraPosition(_cameraPosition!);
    setState(() {});
  }

  _toggleMic() async {
    if (_localAudioTrack!.muted) {
      await _localAudioTrack?.unmute();
    } else {
      await _localAudioTrack?.mute();
    }
    setState(() {});
  }

  void _finishLivestream() {
    setState(() {
      _isFinished = true;
      _isResourceCleared = true;
    });
    ref.read(liveScreenViewModelProvider.notifier).deleteLivestreamRoom(_room!.name!);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(liveScreenViewModelProvider, (_, next) {
      switch (next.isDeleted) {
        case SuccessState<bool>():
          context.popUntilPath('/create_screen');
        case ErrorState(message: final message):
          showSnackbar(context, "error: $message");
        case LoadingState():
          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Closing livestream room...'),
                  ],
                ),
              ),
            );
          }
        case IdleState():
      }
    });
    if (_isDisconnected) {
      return const LiveDisconnectedView();
    } else if (_isRoomClosed) {
      return const LiveEndedView();
    }

    return PopScope(
      canPop: _isResourceCleared,
      onPopInvokedWithResult: (didPop, result) {
        if(didPop){
          return;
        }else{
          _finishLivestream();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: _isVideoTrackLoading
                  ? LoadingIndicator()
                  : _localVideoTrack == null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.videocam_off_outlined, size: 48, color: Colors.white),
                              Text(
                                'Camera is disabled',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        )
                      : VideoTrackRenderer(
                          _localVideoTrack!,
                          fit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                        ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    children: [
                      IconButton.filled(
                        onPressed: () {
                          _finishLivestream();
                        },
                        icon: Icon(Icons.close),
                        color: Colors.black.withAlpha(128),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Live",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red),
                            ),
                            SizedBox(width: 2),
                            Icon(Icons.podcasts, color: Colors.red),
                            SizedBox(width: 4),
                            Icon(Icons.person, color: Colors.white),
                            SizedBox(width: 2),
                            Text("$_totalParticipants", style: Theme.of(context).textTheme.bodyMedium),
                            SizedBox(width: 4),
                            Icon(Icons.favorite, color: Colors.white),
                            SizedBox(width: 2),
                            Text("${_roomLikes.likes}", style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(100),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {
                          _toggleCameraEnabledState();
                        },
                        icon: Icon(
                          _localVideoTrack != null && !_isVideoTrackLoading ? Icons.videocam_off_outlined : Icons.videocam,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _toggleCameraPosition();
                        },
                        icon: Icon(
                          Icons.flip_camera_android,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _toggleMic();
                        },
                        icon: Icon(
                          _localAudioTrack?.muted == true ? Icons.mic_off : Icons.mic,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: LivestreamCommentsView(
                comments: _comments,
              ),
            )
          ],
        ),
      ),
    );
  }
}
