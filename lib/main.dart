import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:university_admission/models/user_model.dart';
import 'package:university_admission/screens/application/ranking_screen.dart';
import 'package:university_admission/screens/auth/registration_screen.dart';
import 'package:university_admission/screens/documents/documents_screen.dart';
import 'services/auth_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/application/application_form_screen.dart';
import 'screens/application/application_status_screen.dart';
import 'screens/application/rankings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = AuthService();
  await authService.init();
  runApp(MyApp(authService: authService));
}

class MyApp extends StatelessWidget {
  final AuthService authService;

  const MyApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>.value(value: authService),
        StreamProvider(
          create: (context) => context.read<AuthService>().authStateChanges,
          initialData: authService.currentUser,
        ),
      ],
      child: MaterialApp(
        title: 'Приемная комиссия',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const ApplicationStatusScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegistrationScreen(),
          '/home': (context) => const HomeScreen(),
          '/application': (context) => const ApplicationFormScreen(),
          '/status': (context) => const ApplicationStatusScreen(),
          '/rankings': (context) =>  RankingScreen(),
          '/documents': (context) => const DocumentsScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserModel?>();
    
    if (user != null) {
      return const HomeScreen();
    }
    
    return const LoginScreen();
  }
}
