import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'services/storage_service.dart';
import 'services/firebase_service.dart';
import 'state/app_state.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI style for immersive luxury glass experience
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.bgDark,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize persistent storage and cloud services
  final storageService = await StorageService.init();
  final firebaseService = FirebaseService.fromStorage(storageService);
  final appState = AppState(
    storageService: storageService,
    firebaseService: firebaseService,
  );

  runApp(DishaMakeoverApp(appState: appState));
}

class DishaMakeoverApp extends StatelessWidget {
  final AppState appState;

  const DishaMakeoverApp({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Disha Makeover',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.luxuryTheme,
      home: MainNavigationScreen(appState: appState),
    );
  }
}
