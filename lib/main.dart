import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'constants/colors.dart';
import 'screens/main_shell.dart';
import 'screens/onboarding_screen.dart';
import 'services/account_service.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/catalog_service.dart';
import 'services/cart_service.dart';
import 'state/auth_state.dart';
import 'state/cart_state.dart';
import 'state/catalog_state.dart';
import 'state/profile_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  final apiClient = ApiClient();

  runApp(MyApp(apiClient: apiClient));
}

class MyApp extends StatelessWidget {
  final ApiClient apiClient;

  const MyApp({super.key, required this.apiClient});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: apiClient),
        Provider<AccountService>(create: (_) => AccountService(apiClient)),
        Provider<AuthService>(create: (_) => AuthService(apiClient)),
        Provider<CatalogService>(create: (_) => CatalogService(apiClient)),
        Provider<CartService>(create: (_) => CartService(apiClient)),
        ChangeNotifierProvider<AuthState>(
          create: (context) => AuthState(context.read<AuthService>()),
        ),
        ChangeNotifierProvider<CatalogState>(
          create: (context) => CatalogState(context.read<CatalogService>()),
        ),
        ChangeNotifierProvider<CartState>(
          create: (context) => CartState(context.read<CartService>()),
        ),
        ChangeNotifierProvider<ProfileState>(
          create: (context) => ProfileState(context.read<AccountService>()),
        ),
      ],
      child: MaterialApp(
        title: 'PhsarRohas',
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: Colors.white,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
              systemNavigationBarColor: Colors.white,
              systemNavigationBarIconBrightness: Brightness.dark,
            ),
            child: child ?? const SizedBox.shrink(),
          );
        },
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
          ),
          useMaterial3: true,
          hoverColor: Colors.transparent,
          textTheme: GoogleFonts.nunitoTextTheme(),
          scaffoldBackgroundColor: Colors.white,
          iconButtonTheme: IconButtonThemeData(
            style: ButtonStyle(
              overlayColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.hovered)) {
                  return Colors.transparent;
                }
                return null;
              }),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
              overlayColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.hovered)) {
                  return Colors.transparent;
                }
                return null;
              }),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              overlayColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.hovered)) {
                  return Colors.transparent;
                }
                return null;
              }),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: ButtonStyle(
              overlayColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.hovered)) {
                  return Colors.transparent;
                }
                return null;
              }),
            ),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.white,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
            ),
            iconTheme: IconThemeData(color: AppColors.textPrimary),
          ),
        ),
        home: const AppBootstrap(),
      ),
    );
  }
}

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  late final Future<void> _restoreFuture;

  @override
  void initState() {
    super.initState();
    _restoreFuture = context.read<AuthState>().restoreSession();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _restoreFuture,
      builder: (context, snapshot) {
        final authState = context.watch<AuthState>();

        if (snapshot.connectionState != ConnectionState.done ||
            authState.isRestoring) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: SizedBox.expand(),
          );
        }

        if (authState.isAuthenticated) {
          return const MainShell();
        }

        return const OnboardingScreen();
      },
    );
  }
}
