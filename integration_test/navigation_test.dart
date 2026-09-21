import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:coop_loto_supa/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Petite pause pour pouvoir observer l'application pendant le test.
  Future<void> pause() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  // ============================================================
  // TEST 1
  // Login → Home → Groups → gamma → retour
  // ============================================================

  testWidgets('Retour depuis GroupDetail', (tester) async {
    // ------------------------------------------------------------
    // 1. Lancer l'application
    // ------------------------------------------------------------

    print('[TEST 1] Lancement de l application');

    app.main();

    await tester.pumpAndSettle();
    await pause();

    // ------------------------------------------------------------
    // 2. Vérifier si l'utilisateur est déjà connecté
    // ------------------------------------------------------------

    final loginFields = find.byType(TextField);

    if (loginFields.evaluate().isNotEmpty) {
      print('[TEST 1] Utilisateur non connecté -> login');

      expect(loginFields, findsNWidgets(2));

      await tester.enterText(
        find.byType(TextField).at(0),
        'user0',
      );

      await pause();

      await tester.enterText(
        find.byType(TextField).at(1),
        'aaaaaa',
      );

      await pause();

      await tester.tap(find.text('Se connecter'));

      await tester.pumpAndSettle();
      await pause();
    } else {
      print('[TEST 1] Utilisateur déjà connecté');
    }

    // ------------------------------------------------------------
    // 3. Vérifier qu'on est arrivé sur Home
    // ------------------------------------------------------------

    print('[TEST 1] Vérification HomePage');

    expect(
      find.textContaining('Coop Loto'),
      findsOneWidget,
    );

    await pause();

    // ------------------------------------------------------------
    // 4. Aller dans "Mes groupes"
    // ------------------------------------------------------------

    print('[TEST 1] Ouverture de GroupsPage');

    await tester.tap(find.byIcon(Icons.group));

    await tester.pumpAndSettle();
    await pause();

    // ------------------------------------------------------------
    // 5. Vérifier que gamma est affiché
    // ------------------------------------------------------------

    print('[TEST 1] Recherche du groupe gamma');

    expect(
      find.text('gamma'),
      findsOneWidget,
    );

    await pause();

    // ------------------------------------------------------------
    // 6. Ouvrir gamma
    // ------------------------------------------------------------

    print('[TEST 1] Clic sur gamma');

    await tester.tap(find.text('gamma'));

    await tester.pumpAndSettle();
    await pause();

    // ------------------------------------------------------------
    // 7. Vérifier qu'on est sur le détail
    // ------------------------------------------------------------

    print('[TEST 1] Vérification GroupDetailPage');

    expect(
      find.text('gamma'),
      findsOneWidget,
    );

    await pause();

    // ------------------------------------------------------------
    // 8. Revenir en arrière
    // ------------------------------------------------------------

    print('[TEST 1] Clic sur retour');

    await tester.tap(find.byIcon(Icons.arrow_back));

    await tester.pumpAndSettle();
    await pause();

    // ------------------------------------------------------------
    // 9. Vérifier qu'on est revenu sur GroupsPage
    // ------------------------------------------------------------

    print('[TEST 1] Vérification retour GroupsPage');

    expect(
      find.text('Groups for user0'),
      findsOneWidget,
    );

    expect(
      find.text('gamma'),
      findsOneWidget,
    );

    print('[TEST 1] TEST REUSSI');
  });

  // ============================================================
  // TEST 2
  // Login → Home → Groups → gamma
  // ============================================================

  testWidgets('Ouverture de GroupDetail', (tester) async {
    // ------------------------------------------------------------
    // 1. Lancer l'application
    // ------------------------------------------------------------

    print('[TEST 2] Lancement de l application');

    app.main();

    await tester.pumpAndSettle();
    await pause();

    // ------------------------------------------------------------
    // 2. Vérifier si l'utilisateur est déjà connecté
    // ------------------------------------------------------------

    final loginFields = find.byType(TextField);

    if (loginFields.evaluate().isNotEmpty) {
      print('[TEST 2] Utilisateur non connecté -> login');

      expect(loginFields, findsNWidgets(2));

      await tester.enterText(
        find.byType(TextField).at(0),
        'user0',
      );

      await pause();

      await tester.enterText(
        find.byType(TextField).at(1),
        'aaaaaa',
      );

      await pause();

      await tester.tap(find.text('Se connecter'));

      await tester.pumpAndSettle();
      await pause();
    } else {
      print('[TEST 2] Utilisateur déjà connecté');
    }

    // ------------------------------------------------------------
    // 3. Vérifier Home
    // ------------------------------------------------------------

    print('[TEST 2] Vérification HomePage');

    expect(
      find.textContaining('Coop Loto'),
      findsOneWidget,
    );

    await pause();

    // ------------------------------------------------------------
    // 4. Aller dans GroupsPage
    // ------------------------------------------------------------

    print('[TEST 2] Ouverture de GroupsPage');

    await tester.tap(find.byIcon(Icons.group));

    await tester.pumpAndSettle();
    await pause();

    // ------------------------------------------------------------
    // 5. Vérifier gamma
    // ------------------------------------------------------------

    print('[TEST 2] Recherche du groupe gamma');

    expect(
      find.text('gamma'),
      findsOneWidget,
    );

    await pause();

    // ------------------------------------------------------------
    // 6. Ouvrir gamma
    // ------------------------------------------------------------

    print('[TEST 2] Clic sur gamma');

    await tester.tap(find.text('gamma'));

    await tester.pumpAndSettle();
    await pause();

    // ------------------------------------------------------------
    // 7. Vérifier qu'on est arrivé sur GroupDetailPage
    // ------------------------------------------------------------

    print('[TEST 2] Vérification GroupDetailPage');

    expect(
      find.text('gamma'),
      findsOneWidget,
    );

    print('[TEST 2] TEST REUSSI');
  });

////////////////////////// test 3: Déconnexion depuis HomePage //////////////////////////////

  testWidgets('Déconnexion depuis HomePage', (tester) async {
    print('[TEST 3] Lancement de l application');
    app.main();
    await tester.pumpAndSettle();
    await pause();

    final loginFields = find.byType(TextField);

    if (loginFields.evaluate().isNotEmpty) {
      print('[TEST 3] Utilisateur non connecté -> login');

      expect(loginFields, findsNWidgets(2));

      await tester.enterText(
        find.byType(TextField).at(0),
        'user0',
      );
      await pause();

      await tester.enterText(
        find.byType(TextField).at(1),
        'aaaaaa',
      );
      await pause();

      print('[TEST 3] Connexion');
      await tester.tap(find.text('Se connecter'));
      await tester.pumpAndSettle();
      await pause();
    } else {
      print('[TEST 3] Utilisateur déjà connecté');
    }

    print('[TEST 3] Vérification HomePage');
    expect(find.textContaining('Coop Loto'), findsOneWidget);
    await pause();

    print('[TEST 3] Ouverture du menu paramètres');
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    await pause();

    print('[TEST 3] Vérification du bouton Se déconnecter');
    expect(find.text('Se déconnecter'), findsOneWidget);
    await pause();

    print('[TEST 3] Clic sur Se déconnecter');
    await tester.tap(find.text('Se déconnecter'));
    await tester.pumpAndSettle();
    await pause();

    print('[TEST 3] Vérification retour LoginPage');

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Nom d\'utilisateur'), findsOneWidget);
    expect(find.text('Mot de passe'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);

    print('[TEST 3] TEST REUSSI');
  });
}