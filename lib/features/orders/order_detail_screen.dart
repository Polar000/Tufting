import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/models/app_models.dart';
import '../../shared/widgets/app_buttons.dart';
import '../../shared/widgets/app_cards.dart';
import '../../shared/widgets/app_indicators.dart';
import '../chat/chat_screen.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: 'Q', decimalDigits: 2);
    final req = order.requestDetails;

    return Scaffold(
      appBar: AppBar(
        title: Text('Pedido ${order.id}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header Card
            AppCard(
              padding: const EdgeInsets.all(20),
              color: AppColors.sand.withValues(alpha: 0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Estado del Pedido',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      StatusChip(status: order.status),
                    ],
                  ),
                  if (order.adminNote != null && order.adminNote!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.sand),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.note_alt_outlined, color: AppColors.terracotta, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Nota del artesano: ${order.adminNote}',
                              style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Visual Timeline
            Text(
              'Seguimiento de Producción',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            OrderTimeline(currentStatus: order.status),
            const SizedBox(height: 28),

            // Design Details
            Text(
              'Detalles de la Alfombra',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      order.imageUrl,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 90,
                        height: 90,
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
                        Text(
                          order.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text('Dimensiones: ${req.widthCm.toInt()} x ${req.heightCm.toInt()} ${req.unit}'),
                        Text('Forma: ${req.shape}'),
                        Text('Lana: ${req.woolType}'),
                        Text('Acabado: ${req.finish}'),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Payment Summary Card
            Text(
              'Información de Pago',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildPaymentRow('Precio Total:', currencyFormat.format(order.totalPrice), false),
                  const SizedBox(height: 8),
                  _buildPaymentRow('Anticipo (50%):', currencyFormat.format(order.depositAmount), order.isDepositPaid),
                  const SizedBox(height: 8),
                  _buildPaymentRow('Saldo Pendiente:', currencyFormat.format(order.remainingBalance), false),
                ],
              ),
            ),
            const SizedBox(height: 28),

            PrimaryButton(
              text: 'Contactar a la Empresa',
              icon: Icons.chat_bubble_outline_rounded,
              width: double.infinity,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ChatScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value, bool isPaid) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            if (isPaid) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Pagado', style: TextStyle(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.bold)),
              )
            ]
          ],
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
