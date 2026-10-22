import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  io.Socket? _socket;

  bool get isConnected => _socket?.connected ?? false;

  void connect({
    required String baseUrl,
    required String token,
    required void Function(dynamic data) onNotification,
    required void Function() onReconnect,
  }) {
    disconnect();

    _socket = io.io(
      baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .enableReconnection()
          .disableAutoConnect()
          .build(),
    );

    _socket!
      ..onConnect((_) {
        onReconnect();
      })
      ..onConnectError((_) {})
      ..onError((_) {})
      ..on('notification', onNotification)
      ..connect();
  }

  void disconnect() {
    _socket?.dispose();
    _socket = null;
  }
}
