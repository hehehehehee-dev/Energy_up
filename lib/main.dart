import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'screens/home_shell.dart';
import 'screens/onboarding_screen.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  try {
    final appState = AppState();
    await appState.load();

    runApp(
      ChangeNotifierProvider.value(
        value: appState,
        child: const AngelApp(),
      ),
    );
  } catch (e, st) {
    print('ERROR IN MAIN: $e');
    print('STACKTRACE: $st');
    rethrow;
  }
}

class AngelApp extends StatelessWidget {
  const AngelApp({super.key});

  @override
  Widget build(BuildContext context) {
    final onboarded = context.select<AppState, bool>((a) => a.onboarded);

    return MaterialApp(
      title: 'EnergyUp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.canvas,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.lavender,
          primary: AppColors.lavender,
        ),
        splashColor: AppColors.lavender.withOpacity(0.08),
        highlightColor: Colors.transparent,
      ),
      home: onboarded ? const HomeShell() : const OnboardingScreen(),
    );
  }
}
