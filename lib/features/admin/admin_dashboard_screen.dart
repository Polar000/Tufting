import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/models/app_models.dart';
import '../../shared/widgets/app_buttons.dart';
import '../../shared/widgets/app_cards.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateNotifier>();
    final orders = appState.orders;
    final currencyFormat = NumberFormat.currency(symbol: 'Q', decimalDigits: 2);

    final pendingQuotes = orders.where((o) => o.status == OrderStatus.solicitudRecibida || o.status == OrderStatus.disenoEnRevision).length;
    final inProduction = orders.where((o) => o.status == OrderStatus.enProduccion || o.status == OrderStatus.enAcabado).length;
    final totalRevenue = orders.where((o) => o.isDepositPaid).fold(0.0, (sum, o) => sum + o.depositAmount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Métricas Generales',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // KPI Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    context,
                    'Solicitudes',
                    '$pendingQuotes',
                    Icons.pending_actions,
                    AppColors.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    'En Taller',
                    '$inProduction',
                    Icons.precision_manufacturing,
                    AppColors.terracotta,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildMetricCard(
              context,
              'Ingresos Recibidos (Anticipos)',
              currencyFormat.format(totalRevenue),
              Icons.attach_money,
              AppColors.oliveGreen,
            ),
            const SizedBox(height: 28),

            Text(
              'Gestión de Cotizaciones y Pedidos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(order.id, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.terracotta)),
                            StatusChip(status: order.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(order.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('Cliente: ${appState.currentUser?.name ?? "Usuario"}'),
                        Text('Precio Actual: Q${order.totalPrice.toStringAsFixed(2)}'),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SecondaryButton(
                              text: 'Gestionar / Cotizar',
                              icon: Icons.edit_note,
                              onPressed: () {
                                _showManageOrderModal(context, appState, order);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: AppColors.warmGray)),
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showManageOrderModal(BuildContext context, AppStateNotifier appState, OrderModel order) {
    final priceController = TextEditingController(text: order.totalPrice.toStringAsFixed(0));
    final noteController = TextEditingController(text: order.adminNote ?? '');
    OrderStatus selectedStatus = order.status;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Gestionar Cotización ${order.id}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Text('Ajustar Precio Final (Q)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'Ej. 1250'),
                  ),
                  const SizedBox(height: 16),
                  Text('Estado del Pedido', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<OrderStatus>(
                    value: selectedStatus,
                    items: OrderStatus.values.map((s) {
                      return DropdownMenuItem(value: s, child: Text(s.label));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedStatus = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('Nota para el cliente', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: noteController,
                    maxLines: 2,
                    decoration: const InputDecoration(hintText: 'Escribe comentarios técnicos sobre el teñido o producción...'),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: 'Guardar y Notificar al Cliente',
                    width: double.infinity,
                    onPressed: () {
                      final newPrice = double.tryParse(priceController.text);
                      appState.updateOrderStatusByAdmin(
                        order.id,
                        selectedStatus,
                        updatedPrice: newPrice,
                        note: noteController.text,
                      );
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cotización/Pedido actualizado correctamente')),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
