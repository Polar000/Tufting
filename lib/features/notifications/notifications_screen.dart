import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_cards.dart';
import '../orders/order_detail_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateNotifier>();
    final notifications = appState.notifications;
    final timeFormat = DateFormat('dd MMM, hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          TextButton(
            onPressed: () {
              context.read<AppStateNotifier>().markAllNotificationsAsRead();
            },
            child: const Text('Marcar leídas'),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Text('No tienes notificaciones pendientes', style: TextStyle(color: AppColors.warmGray)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard(
                    color: notif.isRead
                        ? null
                        : AppColors.terracotta.withValues(alpha: 0.08),
                    onTap: notif.orderId != null
                        ? () {
                            final order = appState.orders.firstWhere(
                              (o) => o.id == notif.orderId,
                              orElse: () => appState.orders.first,
                            );
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order)),
                            );
                          }
                        : null,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: notif.isRead ? AppColors.sand : AppColors.terracotta,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.notifications_active_outlined,
                            size: 20,
                            color: notif.isRead ? AppColors.warmGray : Colors.white,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notif.title,
                                style: TextStyle(
                                  fontWeight: notif.isRead ? FontWeight.bold : FontWeight.w900,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notif.body,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context).textTheme.bodyMedium?.color,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                timeFormat.format(notif.timestamp),
                                style: const TextStyle(fontSize: 11, color: AppColors.warmGray),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
