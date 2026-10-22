import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitbill_frontend/app/core/socket/socket_service.dart';

final socketServiceProvider = Provider<SocketService>((ref) {
  final service = SocketService();

  ref.onDispose(service.disconnect);

  return service;
});
