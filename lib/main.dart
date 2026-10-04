import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/login_page.dart';
import 'screens/groups_page.dart';
import 'screens/group_menu_page.dart';
import 'screens/home_page.dart';
import 'screens/games_page.dart';
import 'screens/euromillions_page.dart';
import 'screens/collect_euromillions_page.dart';
import 'screens/simulate_grid_page.dart';
import 'screens/previous_draws_page.dart';
import 'screens/group_played_grids_page.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/buy_credits_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR');
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
          path: '/group/:groupId/menu',
          builder: (context, state) {
            final group = state.extra as Map<String, dynamic>;
            final username =
                state.uri.queryParameters['username'] ?? '';

            return GroupMenuPage(
              group: group,
              username: username,
            );
          },
        ),
        GoRoute(
          path: '/games',
          builder: (context, state) => const GamesPage(),
        ),

        GoRoute(
          path: '/euromillions',
          builder: (context, state) =>
              const EuromillionsPage(),
        ),
        GoRoute(
          path: '/collect-euromillions',
          builder: (context, state) =>
              const CollectEuromillionsPage(),
        ),
        GoRoute(
          path: '/buy-credits',
          builder: (context, state) {
            return const BuyCreditsPage();
          },
        ),
        GoRoute(
          path: '/group/:groupId/simulate-grid',
          builder: (context, state) {
            final username =
                state.uri.queryParameters['username'] ?? '';

            final groupId =
                int.parse(state.pathParameters['groupId']!);

            return SimulateGridPage(
              groupId: groupId,
              username: username,
            );
          },
        ),
        GoRoute(
          path: '/group/:groupId/previous-draws',
          builder: (context, state) {
            final username =
                state.uri.queryParameters['username'] ?? '';

            final groupId =
                int.parse(state.pathParameters['groupId']!);

            return PreviousDrawsPage(
              groupId: groupId,
              username: username,
            );
          },
        ),

        GoRoute(
          path: '/group/:groupId/played-grids',
          builder: (context, state) {
            final username =
                state.uri.queryParameters['username'] ?? '';

            final groupId =
                int.parse(state.pathParameters['groupId']!);

            return GroupPlayedGridsPage(
              groupId: groupId,
              username: username,
            );
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
