        import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';

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
  final TextEditingController configController = TextEditingController();

  @override
  void initState() {
    super.initState();
    flutterV2ray = FlutterV2ray(
      onStatusChanged: (status) {
        setState(() {
          statusText = status.state.toUpperCase();
          isConnected = (status.state.toLowerCase() == 'connected');
        });
      },
    );
    flutterV2ray.initializeV2Ray();
  }

  Future<void> toggleVPN() async {
    final config = configController.text.trim();
    if (!isConnected && config.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("ကျေးဇူးပြု၍ V2Ray / VLESS / VMess Config Link ထည့်ပါ"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      if (isConnected) {
        await flutterV2ray.stopV2Ray();
      } else {
        if (await flutterV2ray.requestPermission()) {
          await flutterV2ray.startV2Ray(
            remark: "MM Banking VPN",
            config: config,
            blockedApps: null,
          );
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("VPN ခွင့်ပြုချက် (Permission) မရရှိပါ"),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      setState(() {
        configController.text = data.text!;
      });
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
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
                size: 80,
                color: isConnected ? Colors.tealAccent : Colors.redAccent,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              statusText,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isConnected ? Colors.tealAccent : Colors.white70,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: configController,
              maxLines: 3,
              style: const TextStyle(fontSize: 12, color: Colors.white),
              decoration: InputDecoration(
                hintText: "vless:// သို့မဟုတ် vmess:// Config လင့်ခ် ထည့်ပါ...",
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.paste, color: Colors.tealAccent),
                  onPressed: pasteFromClipboard,
                  tooltip: "Paste",
                ),
              ),
            ),
            const SizedBox(height: 30),
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
    );
  }
}
