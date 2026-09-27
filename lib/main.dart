import 'package:flutter/material.dart';
import 'package:health_guard/screens/home_screen.dart';
import 'package:health_guard/providers/health_provider.dart';
import 'package:provider/provider.dart';
import 'package:health_guard/services/notification_service.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(
    ChangeNotifierProvider(
      create: (_) => HealthProvider(),
      child: const HealthGuard(),
    ),
  );

  try {
    await NotificationService.initialize();
    await NotificationService.scheduleDailyHealthTip();
  } catch (e) { /* Notifications not initialized */ }

  FlutterNativeSplash.remove();
}

class HealthGuard extends StatelessWidget {
  const HealthGuard({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Health Guard",
      home: const HomeScreen(),
    );
  }
}