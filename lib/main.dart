import 'package:flutter/material.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MM Banking VPN',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: Colors.tealAccent,
      ),
      home: const VPNHomeScreen(),
    );
  }
}

class VPNHomeScreen extends StatefulWidget {
  const VPNHomeScreen({super.key});

  @override
  State<VPNHomeScreen> createState() => _VPNHomeScreenState();
}

class _VPNHomeScreenState extends State<VPNHomeScreen> {
  late final FlutterV2ray flutterV2ray;
  bool isConnected = false;
  String statusText = "DISCONNECTED";

  final String v2rayConfigLink = "vless://YOUR_MYANMAR_SERVER_CONFIG_HERE";

  @override
  void initState() {
    super.initState();
    flutterV2ray = FlutterV2ray(
      onStatusChanged: (status) {
        setState(() {
          statusText = status.state.toUpperCase();
          isConnected = status.state == 'CONNECTED';
        });
      },
    );
    flutterV2ray.initializeV2Ray();
  }

  Future<void> toggleVPN() async {
    await Permission.notification.request();

    if (isConnected) {
      await flutterV2ray.stopV2Ray();
    } else {
      if (await flutterV2ray.requestPermission()) {
        final V2RayURL parser = FlutterV2ray.parseFromURL(v2rayConfigLink);
        await flutterV2ray.startV2Ray(
          remark: "Myanmar Banking VPN",
          config: parser.fullConfiguration,
          blockedApps: null,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MM Banking VPN"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isConnected
                      ? Colors.tealAccent.withOpacity(0.1)
                      : Colors.redAccent.withOpacity(0.1),
                ),
                child: Icon(
                  isConnected ? Icons.shield : Icons.shield_outlined,
                  size: 90,
                  color: isConnected ? Colors.tealAccent : Colors.redAccent,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isConnected ? Colors.tealAccent : Colors.white70,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: toggleVPN,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  backgroundColor: isConnected ? Colors.redAccent : Colors.tealAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  isConnected ? "DISCONNECT" : "CONNECT",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isConnected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
