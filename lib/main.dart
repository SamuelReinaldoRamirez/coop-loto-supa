import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/login_page.dart';
import 'screens/groups_page.dart';
import 'screens/group_detail_page.dart';
import 'screens/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) {
            final username = state.extra as String;
            return HomePage(username: username);
          },
        ),

        GoRoute(
          path: '/groups',
          builder: (context, state) {
            final username = state.extra as String;
            return GroupsPage(username: username);
          },
        ),
        GoRoute(
          path: '/group/:id',
          builder: (context, state) {
            final group = state.extra as Map<String, dynamic>?;
            final username = state.uri.queryParameters['username'] ?? '';
            return GroupDetailPage(group: group ?? {}, username: username);
          },
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Coop Loto',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      routerConfig: router,
    );
  }
}
