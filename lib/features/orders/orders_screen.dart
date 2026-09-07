import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_cards.dart';
import '../../shared/widgets/app_indicators.dart';
import '../create_rug/create_rug_wizard_screen.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateNotifier>();
    final orders = appState.orders;
    final currencyFormat = NumberFormat.currency(symbol: 'Q', decimalDigits: 2);
    final dateFormat = DateFormat('dd MMM, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Pedidos'),
      ),
      body: orders.isEmpty
          ? EmptyStateWidget(
              title: 'Todavía no tienes pedidos',
              message: 'Diseña tu primera alfombra personalizada de lana y síguela paso a paso.',
              icon: Icons.inventory_2_outlined,
              buttonText: 'Crear mi primera alfombra',
              onButtonPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CreateRugWizardScreen()),
                );
              },
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: AppCard(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => OrderDetailScreen(order: order),
                        ),
                      );
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            order.imageUrl,
                            width: 85,
                            height: 85,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 85,
                              height: 85,
                              color: AppColors.sand,
                              child: const Icon(Icons.palette_outlined, color: AppColors.warmGray),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    order.id,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: AppColors.terracotta,
                                    ),
                                  ),
                                  Text(
                                    dateFormat.format(order.date),
                                    style: const TextStyle(fontSize: 11, color: AppColors.warmGray),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                order.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  StatusChip(status: order.status),
                                  Text(
                                    currencyFormat.format(order.totalPrice),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
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
