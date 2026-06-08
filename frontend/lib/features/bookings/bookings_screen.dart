import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../models/booking.dart';

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen> {
  String? _role; // null = alle, 'SENDER', 'TRAVELER'

  @override
  void initState() {
    super.initState();
    Future.microtask(_reload);
  }

  void _reload() {
    ref.read(bookingsControllerProvider.notifier).load(role: _role);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookingsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meine Buchungen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Aktualisieren',
            onPressed: _reload,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<String?>(
              segments: const [
                ButtonSegment(value: null, label: Text('Alle')),
                ButtonSegment(value: 'SENDER', label: Text('Als Sender')),
                ButtonSegment(value: 'TRAVELER', label: Text('Als Traveler')),
              ],
              selected: {_role},
              onSelectionChanged: (s) {
                setState(() => _role = s.first);
                _reload();
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: state.when(
              data: (bookings) => _BookingList(bookings: bookings),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  const _BookingList({required this.bookings});

  final List<BookingSummary> bookings;

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return const Center(child: Text('Noch keine Buchungen.'));
    }
    return ListView.separated(
      itemCount: bookings.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final b = bookings[i];
        final style = bookingStatusStyle(b.status);
        return ListTile(
          title: Text(
            b.route,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            '${b.packageTitle} · ${b.totalAmount.toStringAsFixed(2)} ${b.currency}',
          ),
          trailing: Chip(
            label: Text(style.label),
            backgroundColor: style.color.withValues(alpha: 0.15),
            labelStyle: TextStyle(color: style.color),
          ),
          onTap: () => context.push('/chat/${b.id}'),
        );
      },
    );
  }
}
