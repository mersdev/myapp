import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'presentation/providers/set_shifting_game_provider.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/email_verification_screen.dart';
import 'presentation/screens/set_shifting_game_screen.dart';
import 'presentation/screens/stats/stats_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load();

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => SetShiftingGameProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cognitive Training Games',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: StreamBuilder<AuthState>(
        stream: AuthService.instance.authStateChanges,
        builder: (context, snapshot) {
          // Show loading indicator while checking auth state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // Check if user is authenticated and email is verified
          if (snapshot.hasData && snapshot.data?.session != null) {
            final user = AuthService.instance.currentUser;
            
            // If email is not verified, show verification screen
            if (user != null && !user.emailConfirmedAt!.isNotEmpty) {
              return const EmailVerificationScreen();
            }

            // If authenticated and verified, show game screen
            return Scaffold(
              appBar: AppBar(
                title: const Text('Cognitive Training Games'),
              ),
              body: const SetShiftingGameScreen(),
              bottomNavigationBar: BottomNavigationBar(
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.logout),
                    label: 'Logout',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.bar_chart),
                    label: 'Stats',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.more_horiz),
                    label: 'Other',
                  ),
                ],
                onTap: (index) {
                  if (index == 0) AuthService.instance.signOut(); // Logout
                  if (index == 1) Navigator.push(context, MaterialPageRoute(builder: (context) => const StatsScreen())); // Navigate to Stats
                },
              ),
            );
          }

          // If not authenticated, show login screen
          return const LoginScreen();
        },
      ),
    );
  }
}
