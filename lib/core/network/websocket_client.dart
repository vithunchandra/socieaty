import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:socket_io_client/socket_io_client.dart';

part 'websocket_client.g.dart';

@riverpod
Socket websocketClient(Ref ref, String url, String? token) {
  debugPrint('url: $url');
  return io(url, OptionBuilder().setTransports(['websocket']).setExtraHeaders({'authorization': 'Bearer $token'}).build());
}
