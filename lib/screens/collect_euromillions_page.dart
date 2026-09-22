import 'package:flutter/material.dart';
import '../services/collect_service.dart';

class CollectEuromillionsPage extends StatefulWidget {
  const CollectEuromillionsPage({super.key});

  @override
  State<CollectEuromillionsPage> createState() =>
      _CollectEuromillionsPageState();
}

class _CollectEuromillionsPageState
    extends State<CollectEuromillionsPage> {
  DateTime? periode;

  final CollectService _collect = CollectService.instance;

  @override
  void initState() {
    super.initState();

    // Si une collecte est déjà en cours lorsque l'on revient
    // sur cette page, on attend simplement sa fin.
    if (_collect.isCollecting) {
      _waitForCollect();
    }
  }

  Future<void> _waitForCollect() async {
    try {
      await _collect.collect();
    } catch (_) {
      // L'erreur sera gérée plus proprement plus tard.
    }

    if (!mounted) return;

    setState(() {});
  }

  Future<void> _startCollect() async {
    setState(() {});

    try {
      await _collect.collect();
    } catch (_) {
      // Gestion des erreurs à améliorer ensuite.
    }

    if (!mounted) return;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collecte Euromillions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Période',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: _collect.isCollecting
                  ? null
                  : () {
                      // Calendrier à faire ensuite
                    },
              icon: const Icon(Icons.calendar_month),
              label: Text(
                periode == null
                    ? 'Sélectionner une période'
                    : '${periode!.day}/${periode!.month}/${periode!.year}',
              ),
            ),

            const Spacer(),

            if (_collect.isCollecting)
              const Center(
                child: CircularProgressIndicator(),
              ),

            if (!_collect.isCollecting &&
                _collect.lastMessage != null)
              Center(
                child: Text(
                  _collect.lastMessage!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _collect.isCollecting
                    ? null
                    : _startCollect,
                icon: const Icon(Icons.cloud_download),
                label: const Text('Collect'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import '../services/collect_service.dart';

// class CollectEuromillionsPage extends StatefulWidget {
//   const CollectEuromillionsPage({super.key});

//   @override
//   State<CollectEuromillionsPage> createState() =>
//       _CollectEuromillionsPageState();
// }

// class _CollectEuromillionsPageState
//     extends State<CollectEuromillionsPage> {
//   DateTime? periode;

//   final CollectService _collect = CollectService.instance;

//   @override
//   void initState() {
//     super.initState();

//     // Si une collecte est déjà en cours lorsque l'on revient
//     // sur cette page, on attend simplement sa fin.
//     if (_collect.isCollecting) {
//       _waitForCollect();
//     }
//   }

//   Future<void> _waitForCollect() async {
//     try {
//       await _collect.collect();
//     } catch (_) {
//       // L'erreur sera gérée plus proprement plus tard.
//     }

//     if (!mounted) return;

//     setState(() {});
//   }

//   Future<void> _startCollect() async {
//     setState(() {});

//     try {
//       await _collect.collect();
//     } catch (_) {
//       // Gestion des erreurs à améliorer ensuite.
//     }

//     if (!mounted) return;

//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Collecte Euromillions'),
//       ),

//       body: Padding(
//         padding: const EdgeInsets.all(16),

//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Période',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),

//             const SizedBox(height: 12),

//             OutlinedButton.icon(
//               onPressed: _collect.isCollecting
//                   ? null
//                   : () {
//                       // Calendrier à faire ensuite
//                     },
//               icon: const Icon(Icons.calendar_month),
//               label: Text(
//                 periode == null
//                     ? 'Sélectionner une période'
//                     : '${periode!.day}/${periode!.month}/${periode!.year}',
//               ),
//             ),

//             const Spacer(),

//             // Indicateur de chargement
//             if (_collect.isCollecting)
//               const Center(
//                 child: CircularProgressIndicator(),
//               ),

//             // Message retourné par le backend
//             if (!_collect.isCollecting &&
//                 _collect.lastMessage != null)
//               Center(
//                 child: Text(
//                   _collect.lastMessage!,
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),

//             const SizedBox(height: 16),

//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 onPressed: _collect.isCollecting
//                     ? null
//                     : _startCollect,
//                 icon: const Icon(Icons.cloud_download),
//                 label: const Text('Collect'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // import 'package:flutter/material.dart';
// // import '../services/collect_service.dart';

// // class CollectEuromillionsPage extends StatefulWidget {
// //   const CollectEuromillionsPage({super.key});

// //   @override
// //   State<CollectEuromillionsPage> createState() =>
// //       _CollectEuromillionsPageState();
// // }

// // class _CollectEuromillionsPageState
// //     extends State<CollectEuromillionsPage> {

// //   DateTime? periode;

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Collecte Euromillions'),
// //       ),

// //       body: Padding(
// //         padding: const EdgeInsets.all(16),

// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             const Text(
// //               'Période',
// //               style: TextStyle(
// //                 fontSize: 18,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),

// //             const SizedBox(height: 12),

// //             OutlinedButton.icon(
// //               onPressed: () {
// //                 // Calendrier à faire ensuite
// //               },
// //               icon: const Icon(Icons.calendar_month),
// //               label: Text(
// //                 periode == null
// //                     ? 'Sélectionner une période'
// //                     : '${periode!.day}/${periode!.month}/${periode!.year}',
// //               ),
// //             ),

// //             const Spacer(),

// //             SizedBox(
// //               width: double.infinity,
// //               child: ElevatedButton.icon(
// //                 onPressed: () {
// //                   // Collecte à implémenter ensuite
// //                 },
// //                 icon: const Icon(Icons.cloud_download),
// //                 label: const Text('Collect'),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }