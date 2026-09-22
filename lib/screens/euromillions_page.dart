import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';

class EuromillionsPage extends StatefulWidget {
  const EuromillionsPage({super.key});

  @override
  State<EuromillionsPage> createState() =>
      _EuromillionsPageState();
}

class _EuromillionsPageState
    extends State<EuromillionsPage> {

  final ApiService api = ApiService();
  final AuthService _auth = AuthService.instance;
  String? _pseudo;

  bool loading = true;

  List<dynamic> draws = [];

  @override
  void initState() {
    super.initState();
    _loadPseudo();
    load();
  }

  Future<void> _loadPseudo() async {
    final pseudo = await _auth.getPseudo();

    if (!mounted) return;

    setState(() {
      _pseudo = pseudo;
    });
  }


  Future<void> load() async {

    final data = await api.fetchEuromillionsDraws();

    setState(() {
      draws = data;
      loading = false;
    });
  }

  Widget ball(int n, Color c) {

    return CircleAvatar(
      radius: 16,
      backgroundColor: c,
      child: Text(
        '$n',
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Euromillions'),
        actions: [
          if (_pseudo == 'adminsam')
            IconButton(
              icon: const Icon(Icons.cloud_download),
              onPressed: () {
                context.push('/collect-euromillions');
              },
            ),
        ],
      ),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: draws.length,
              itemBuilder: (context, i) {

                final d = draws[i];

                return Card(
                  child: ListTile(

                    title: Row(
                      children: [

                        for (final n in [
                          d['numero_1'],
                          d['numero_2'],
                          d['numero_3'],
                          d['numero_4'],
                          d['numero_5'],
                        ])
                          Padding(
                            padding: const EdgeInsets.only(
                              right: 4,
                            ),
                            child: ball(n, Colors.blue),
                          ),

                        const SizedBox(width: 8),

                        ball(d['etoile_1'], Colors.orange),
                        const SizedBox(width: 4),
                        ball(d['etoile_2'], Colors.orange),
                      ],
                    ),

                    // title: Row(
                    //   children: [

                    //     for (final n in [
                    //       d['n1'],
                    //       d['n2'],
                    //       d['n3'],
                    //       d['n4'],
                    //       d['n5'],
                    //     ])
                    //       Padding(
                    //         padding: const EdgeInsets.only(
                    //           right: 4,
                    //         ),
                    //         child: ball(n, Colors.blue),
                    //       ),

                    //     const SizedBox(width: 8),

                    //     ball(d['e1'], Colors.orange),
                    //     const SizedBox(width: 4),
                    //     ball(d['e2'], Colors.orange),
                    //   ],
                    // ),

                    subtitle: Text(
                      '${d['date']}\n'
                      'Jackpot : ${d['jackpot']} €\n'
                      'Gagnants : ${d['gagnants']}',
                    ),

                    isThreeLine: true,

                    onTap: () {
                      context.push(
                        '/euromillions/${d['id']}',
                        extra: d,
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}