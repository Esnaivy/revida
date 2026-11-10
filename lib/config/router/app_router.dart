import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:revida/config/config.dart';
import 'package:revida/config/theme/theme_controller.dart';
import 'package:revida/features/auth/presentation/cubits/auth/auth_cubit.dart';
import 'package:revida/features/auth/presentation/screens/screens.dart';
import 'package:revida/features/pages/presentation/screens.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final authCubit = context.read<AuthCubit>();

    _router = GoRouter(
      initialLocation: '/splash',

      refreshListenable: GoRouterRefreshStream(authCubit.stream),

      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const CheckAuthStatusScreen(),
        ),

        //! Login / Register
        GoRoute(
          path: '/login',
          name: LoginScreen.name,
          builder: (context, state) => LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          name: RegisterScreen.name,
          builder: (context, state) => RegisterScreen(),
        ),

        GoRoute(
          path: '/profile',
          name: ProfileScreen.name,
          builder: (context, state) => ProfileScreen(),
        ),

        //! Vistas
        GoRoute(
          path: '/',
          name: HomeScreen.name,
          builder: (context, state) => HomeScreen(),
        ),

        GoRoute(
          path: '/camara',
          name: CamaraScreen.name,
          builder: (context, state) => CamaraScreen(),
        ),

        GoRoute(
          path: '/residuos',
          name: ResiduosScreen.name,
          builder: (context, state) => ResiduosScreen(),
        ),

        GoRoute(
          path: '/stats',
          name: StatsScreen.name,
          builder: (context, state) => StatsScreen(),
        ),

        GoRoute(
          path: '/history',
          name: HistorialScreen.name,
          builder: (context, state) => HistorialScreen(),
        ),

        GoRoute(
          path: '/analisis',
          name: AnalisisScreen.name,
          builder: (context, state) {
            final imagePath = state.extra as String;

            return AnalisisScreen(imagePath: imagePath);
          },
        ),
      ],

      redirect: (context, state) {
        final authState = authCubit.state;

        final isGoingToSplash = state.matchedLocation == '/splash';
        final isGoingToLogin = state.matchedLocation == '/login';
        final isGoingToRegister = state.matchedLocation == '/register';

        // The first session check stays on the splash screen. AuthLoading
        // during login or register must stay on that screen: leaving it
        // cancels the Google account picker and the attempt looks like it
        // did nothing.
        if (authState is AuthInitial ||
            (authState is AuthLoading && isGoingToSplash)) {
          return isGoingToSplash ? null : '/splash';
        }

        final isAuthenticated = authState is Authenticated;

        if (!isAuthenticated) {
          if (isGoingToLogin || isGoingToRegister) return null;
          return '/login';
        }

        if (isGoingToLogin || isGoingToRegister || isGoingToSplash) {
          return '/';
        }

        return null;
      },
    );
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeScope.of(context);

    return ListenableBuilder(
      listenable: theme,
      builder: (context, _) {
        return MaterialApp.router(
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
          theme: lightMode,
          darkTheme: darkMode,
          themeMode: theme.mode,
        );
      },
    );
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream stream) {
    stream.listen((_) => notifyListeners());
  }
}
