import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../services/collect_service.dart';
import '../services/api_service.dart';

class CollectEuromillionsPage extends StatefulWidget {
  const CollectEuromillionsPage({super.key});

  @override
  State<CollectEuromillionsPage> createState() =>
      _CollectEuromillionsPageState();
}

class _CollectEuromillionsPageState
    extends State<CollectEuromillionsPage> {
  final CollectService _collect = CollectService.instance;
  final ApiService _api = ApiService();

  bool _showCalendar = false;

  DateTime _focusedDay = DateTime.now();
  DateTime? _startDate;
  DateTime? _endDate;

final Set<DateTime> _collectedDates = {};

  @override
  void initState() {
    super.initState();
    _loadCollectedDates();

    if (_collect.isCollecting) {
      _waitForCollect();
    }
  }

  Future<void> _loadCollectedDates() async {
    try {
      final dates = await _api.fetchCollectedEuromillionsDates();

      if (!mounted) return;

      setState(() {
        _collectedDates
          ..clear()
          ..addAll(dates);
      });
    } catch (e) {
      debugPrint(
        'Erreur lors de la récupération des dates collectées : $e',
      );
    }
  }


  Future<void> _waitForCollect() async {
    try {
      await _collect.collect();

      await _loadCollectedDates();
    } catch (e) {
      debugPrint(
        'Erreur lors de la collecte : $e',
      );
    }

    if (!mounted) return;

    setState(() {});
  }


  // Future<void> _waitForCollect() async {
  //   try {
  //     await _collect.collect();
  //   } catch (_) {}

  //   if (!mounted) return;

  //   setState(() {});
  // }

  Future<void> _startCollect() async {
    setState(() {});

    try {
      if (_startDate == null) {
        // --------------------------------------------------
        // AUCUNE DATE
        // --------------------------------------------------
        // On récupère le dernier tirage.
        await _collect.collect();
      } else {
        // --------------------------------------------------
        // UNE OU DEUX DATES
        // --------------------------------------------------

        await _collect.collect(
          startDate: _startDate,
          endDate: _endDate,
        );
      }

      // La collecte peut avoir ajouté de nouvelles dates.
      // On recharge donc les dates présentes en BDD.
      await _loadCollectedDates();

    } catch (e) {
      debugPrint(
        'Erreur lors de la collecte : $e',
      );
    }

    if (!mounted) return;

    setState(() {});
  }



  // Future<void> _startCollect() async {
  //   setState(() {});

  //   try {
  //     await _collect.collect();
  //   } catch (_) {}

  //   if (!mounted) return;

  //   setState(() {});
  // }

  String get _periodeLabel {
    if (_startDate == null) {
      return 'Sélectionner une période';
    }

    if (_endDate == null) {
      return _formatDate(_startDate!);
    }

    return '${_formatDate(_startDate!)} → ${_formatDate(_endDate!)}';
  }

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}';
  }

  bool _isCollected(DateTime day) {
    return _collectedDates.any((d) => isSameDay(d, day));
  }

  void _onDaySelected(DateTime selectedDay) {
    setState(() {
      // Aucun jour sélectionné
      if (_startDate == null) {
        _startDate = selectedDay;
        _endDate = null;
        return;
      }

      // Un seul jour déjà sélectionné
      if (_endDate == null) {
        // Reclick sur le même jour => on efface
        if (isSameDay(selectedDay, _startDate)) {
          _startDate = null;
          return;
        }

        // Deuxième date => création de la période
        if (selectedDay.isBefore(_startDate!)) {
          _endDate = _startDate;
          _startDate = selectedDay;
        } else {
          _endDate = selectedDay;
        }
        return;
      }

      // Une période existe déjà : on recommence
      _startDate = selectedDay;
      _endDate = null;
    });
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

            // Bouton calendrier
            OutlinedButton.icon(
              onPressed: _collect.isCollecting
                  ? null
                  : () {
                      setState(() {
                        _showCalendar = !_showCalendar;
                      });
                    },
              icon: const Icon(Icons.calendar_month),
              label: Text(_periodeLabel),
            ),

            const SizedBox(height: 12),

            // Calendrier
            if (_showCalendar)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      // Choix de l'année
                      Row(
                        children: [
                          const Text(
                            'Année',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 12),
                          DropdownButton<int>(
                            value: _focusedDay.year,
                            items: List.generate(27, (i) => 2004 + i)
                                .map(
                                  (year) => DropdownMenuItem(
                                    value: year,
                                    child: Text('$year'),
                                  ),
                                )
                                .toList(),
                            onChanged: (year) {
                              if (year == null) return;

                              setState(() {
                                _focusedDay = DateTime(
                                  year,
                                  _focusedDay.month,
                                );
                              });
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      TableCalendar(
                        locale: 'fr_FR',
                        firstDay: DateTime(2004, 1, 1),
                        lastDay: DateTime(2030, 12, 31),
                        focusedDay: _focusedDay,

                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                        ),

                        calendarFormat: CalendarFormat.month,

                        selectedDayPredicate: (day) =>
                            isSameDay(day, _startDate),

                        rangeStartDay: _startDate,
                        rangeEndDay: _endDate,
                        rangeSelectionMode: RangeSelectionMode.toggledOff,

                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                        },

                        onDaySelected: (selected, focused) {
                          _focusedDay = focused;
                          _onDaySelected(selected);
                        },
                        calendarBuilders: CalendarBuilders(
                          // Jours déjà collectés
                          defaultBuilder: (context, day, focused) {
                            if (!_isCollected(day)) return null;

                            return Container(
                              margin: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${day.day}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },

                          // Aujourd'hui
                          todayBuilder: (context, day, focused) {
                            final isCollected = _isCollected(day);

                            return Container(
                              margin: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isCollected ? Colors.green : null,
                                border: Border.all(
                                  color: Colors.orange,
                                  width: 2,
                                ),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${day.day}',
                                style: TextStyle(
                                  color: isCollected ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),

                      ),
                    ],
                  ),
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
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
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

  Widget _rangeCircle(DateTime day) {
    return Container(
      margin: const EdgeInsets.all(6),
      decoration: const BoxDecoration(
        color: Colors.deepPurple,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
