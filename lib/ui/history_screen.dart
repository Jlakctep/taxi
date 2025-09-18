import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/history_provider.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('История поездок')),
      body: ListView.separated(
        itemCount: history.rides.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final ride = history.rides[index];
          return ListTile(
            title: Text('₴${ride.price.toStringAsFixed(2)} • ${(ride.distanceMeters / 1000).toStringAsFixed(1)} км'),
            subtitle: Text('${ride.date}'),
          );
        },
      ),
    );
  }
}


