import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:livekit_client/livekit_client.dart' as livekit;
import 'package:socieaty/core/constants.dart';
import 'package:socieaty/core/theme/app_pallete.dart';
import 'package:socieaty/core/utils/custom_extension.dart';
import 'package:socieaty/core/utils/show_snackbar.dart';
import 'package:socieaty/features/livestream/model/live_room.dart';
import 'package:socieaty/features/livestream/model/livestream_comment.dart';
import 'package:socieaty/features/livestream/model/livestream_likes.dart';
import 'package:socieaty/features/livestream/model/send_livestream_like_response.dart';
import 'package:socieaty/features/livestream/provider/join_livestream_provider.dart';
import 'package:socieaty/features/livestream/view/live_disconnected_view.dart';
import 'package:socieaty/features/livestream/view/live_ended_view.dart';
import 'package:socieaty/features/livestream/view/livestream_comments_view.dart';
import 'package:socieaty/features/livestream/viewmodel/livestream_view_model.dart';
import 'package:socieaty/shared/view_state.dart';
import 'package:socieaty/shared/widgets/error_screen.dart';
import 'package:socieaty/shared/widgets/loading_indicator.dart';

class LivestreamView extends ConsumerStatefulWidget {
  final LiveRoom roomData;
  const LivestreamView(this.roomData, {super.key});

  @override
  ConsumerState<LivestreamView> createState() => _LivestreamViewState();
}

class _LivestreamViewState extends ConsumerState<LivestreamView> {
  late Room _room;
  late EventsListener _roomListener;
  RemoteParticipant? _streamer;
  RemoteVideoTrack? _streamerVideoTrack;
  final TextEditingController _commentController = TextEditingController();
  String _filterSelection = "All";
  bool _showComments = true;
  bool _isLoading = false;
  bool _isRoomClosed = false;
  bool _isDisconnected = false;

  final List<LivestreamComment> _comments = [];
  int _totalParticipants = 0;
  late LivestreamLikes _roomLikes;
  bool _isLiked = false;
  Timer? _debounce;
  static const _debounceDuration = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _room = Room(
      roomOptions: RoomOptions(
        dynacast: true,
        adaptiveStream: true,
      ),
    );
    _roomListener = _room.createListener();
    _roomLikes = LivestreamLikes(roomName: '', likes: 0);
  }

  @override
  void didUpdateWidget(covariant LivestreamView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_room.isDisposed || _room.connectionState != livekit.ConnectionState.disconnected) {
      _room = Room(
        roomOptions: RoomOptions(
          dynacast: true,
          adaptiveStream: true,
        ),
      );
      _roomListener = _room.createListener();
      _roomLikes = LivestreamLikes(roomName: '', likes: 0);
    }
  }

  @override
  void dispose() {
    (() async {
      _debounce?.cancel();
      _commentController.dispose();
      _streamer?.removeListener(_onStreamerChange);
      _room.removeListener(_onRoomChange);
      await _roomListener.dispose();
      try {
        if (_room.connectionState == livekit.ConnectionState.connected) {
          await _room.disconnect();
        }
      } catch (error) {
        if (mounted) {
          showSnackbar(context, error.toString(), isError: true);
        }
      }
      await _room.dispose();
    })();
    super.dispose();
  }

  _connectToLivestream(String token) async {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
    try {
      _roomListener = _room.createListener();
      await _room.connect(AppConstants.livestreamServerUrl, token);
      debugPrint(_room.connectionState.toString());
      _room.addListener(_onRoomChange);
      _setupListener();
      await _subscribeMedia();
    } on Exception catch (error) {
      debugPrint("error: $error");
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onRoomChange() {
    if (mounted) {
      _totalParticipants = _room.remoteParticipants.length;
      setState(() {});
    }
  }

  void _onStreamerChange() {
    RemoteVideoTrack? pub;
    var visibleVideos = _streamer?.videoTrackPublications.where((pub) {
      return pub.enabled && !pub.muted;
    });
    if (visibleVideos != null && visibleVideos.isNotEmpty) {
      pub = visibleVideos.first.track;
    }
    if (mounted) {
      setState(() {
        _streamerVideoTrack = pub;
      });
    }
  }

  _setupListener() {
    _roomListener
      ..on<RoomDisconnectedEvent>((event) {
        if (event.reason != null) {
          _isDisconnected = false;
          _isRoomClosed = false;

          if (event.reason == DisconnectReason.disconnected) {
            _isDisconnected = true;
          } else if (event.reason == DisconnectReason.roomDeleted) {
            _isRoomClosed = true;
          } else {
            _isDisconnected = true;
          }
        }
      })
      ..on<DataReceivedEvent>((event) {
        debugPrint("Test Comment");
        final decodedData = utf8.decode(event.data);
        final Map<String, dynamic> dataJson = jsonDecode(decodedData);
        debugPrint("topic: ${event.topic}");
        if (event.topic == 'like') {
          debugPrint("like data: $dataJson");
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

  _subscribeMedia() async {
    for (RemoteParticipant remoteParticipant in _room.remoteParticipants.values) {
      if (remoteParticipant.attributes['isStreamer'] == "true") {
        for (RemoteTrackPublication<RemoteVideoTrack> remoteVideoTrackPublication in remoteParticipant.videoTrackPublications) {
          if (remoteVideoTrackPublication.enabled) {
            _streamerVideoTrack = remoteVideoTrackPublication.track;
          }
        }
        _streamer = remoteParticipant;
        _streamer?.addListener(_onStreamerChange);
      }
    }
  }

  _onLiked() {
    if (_debounce?.isActive ?? false) {
      _debounce?.cancel();
    }
    _debounce = Timer(_debounceDuration, () {
      ref.read(livestreamViewModelProvider(roomName: _room.name!).notifier).sendLike(_isLiked);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisconnected) {
      return const LiveDisconnectedView();
    } else if (_isRoomClosed) {
      return const LiveEndedView();
    }

    ref.listen(livestreamViewModelProvider(roomName: widget.roomData.roomName), (_, next) {
      switch (next.likes) {
        case SuccessState<SendLivestreamLikeResponse>(data: final data):
          debugPrint("isLiked: ${data.isLiked}");
          _isLiked = data.isLiked;
          setState(() {});
        case ErrorState(message: final message):
          showSnackbar(context, message, isError: true);
        case LoadingState():
        case IdleState():
      }
    });

    return ref.watch(joinLivestreamProvider(widget.roomData.roomName)).when(
      data: (data) {
        if (_room.connectionState != livekit.ConnectionState.connected) {
          _connectToLivestream(data);
        }
        return GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity! > 0) {
              setState(() {
                _showComments = false;
              });
            } else if (details.primaryVelocity! < 0) {
              setState(() {
                _showComments = true;
              });
            }
          },
          child: _isLoading
              ? LoadingIndicator()
              : Scaffold(
                  body: Stack(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: _streamerVideoTrack == null
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.videocam_off_outlined, size: 48, color: Colors.white),
                                    Text(
                                      'Kamera dinonaktifkan',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              )
                            : VideoTrackRenderer(
                                renderMode: VideoRenderMode.auto,
                                _streamerVideoTrack!,
                                fit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                              ),
                      ),

                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.grey[300],
                                  child: const Icon(Icons.person),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.roomData.owner.name,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.circle,
                                                  color: Colors.white,
                                                  size: 8,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  'LIVE',
                                                  style: Theme.of(context).textTheme.bodySmall,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(
                                            Icons.remove_red_eye,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "$_totalParticipants",
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                          const Icon(
                                            Icons.favorite,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "${_roomLikes.likes}",
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  color: Colors.black87,
                                  itemBuilder: (context) => [
                                    'Restaurant',
                                    'Customer',
                                    'All',
                                  ].map((String value) {
                                    return PopupMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: AppPallete.primaryColor,
                                            ),
                                      ),
                                      onTap: () {
                                        FocusManager.instance.primaryFocus?.unfocus();
                                        setState(() {
                                          _filterSelection = value;
                                        });
                                      },
                                    );
                                  }).toList(),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.white30),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _filterSelection.toCapitalized(),
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: AppPallete.primaryColor,
                                              ),
                                        ),
                                        const Icon(Icons.arrow_drop_down, color: Colors.white),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Overlay content
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: SafeArea(
                          child: AnimatedOpacity(
                            opacity: _showComments ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: IgnorePointer(
                              ignoring: !_showComments,
                              child: Column(
                                children: [
                                  LivestreamCommentsView(
                                    comments: _comments,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.black.withAlpha(128),
                                      ),
                                      child: SafeArea(
                                        top: false,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                child: TextField(
                                                  controller: _commentController,
                                                  style: Theme.of(context).textTheme.bodyLarge,
                                                  decoration: InputDecoration.collapsed(
                                                    hintText: 'Komen disini...',
                                                    hintFadeDuration: const Duration(milliseconds: 200),
                                                    border: InputBorder.none,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              padding: EdgeInsets.zero,
                                              icon: const Icon(Icons.send, color: Colors.white),
                                              onPressed: () {
                                                if (_commentController.text.isNotEmpty) {
                                                  if (_room.name != null && _room.name!.isNotEmpty) {
                                                    debugPrint(_room.name!);
                                                    ref
                                                        .read(livestreamViewModelProvider(roomName: _room.name!).notifier)
                                                        .sendComment(_commentController.text);
                                                    _commentController.clear();
                                                  } else {
                                                    showSnackbar(context, "Nama ruangan livestream kosong");
                                                  }
                                                }
                                              },
                                            ),
                                            IconButton(
                                              padding: EdgeInsets.zero,
                                              icon: _isLiked
                                                  ? Icon(Icons.favorite, color: Colors.red)
                                                  : Icon(Icons.favorite_border, color: Colors.white),
                                              onPressed: () {
                                                _isLiked = !_isLiked;
                                                // debugPrint("isLiked: $_isLiked");
                                                _onLiked();
                                                setState(() {});
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
      error: (error, stacktrace) {
        return ErrorScreen(message: error.toString());
      },
      loading: () {
        return LoadingIndicator();
      },
    );
  }
}
