import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/models/app_models.dart';
import '../../shared/widgets/app_buttons.dart';
import '../create_rug/create_rug_wizard_screen.dart';

class RugDetailModal extends StatelessWidget {
  final InspirationRugModel rug;

  const RugDetailModal({super.key, required this.rug});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: 'Q', decimalDigits: 0);

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.sand,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      rug.imageUrl,
                      height: 280,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 280,
                        color: AppColors.sand,
                        child: const Icon(Icons.palette_outlined, size: 60, color: AppColors.warmGray),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.terracotta.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          rug.category,
                          style: const TextStyle(
                            color: AppColors.terracotta,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Text(
                        'Aproximado ~ ${currencyFormat.format(rug.estimatedPrice)}',
                        style: const TextStyle(
                          color: AppColors.terracotta,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    rug.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    rug.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 15,
                          height: 1.4,
                        ),
                  ),
                  const SizedBox(height: 24),

                  // Detail Pills
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.sand),
                    ),
                    child: Column(
                      children: [
                        _buildSpecRow(context, Icons.straighten, 'Tamaño sugerido', rug.sizeDescription),
                        const Divider(height: 20),
                        _buildSpecRow(context, Icons.dry_cleaning, 'Materiales', rug.materialInfo),
                        const Divider(height: 20),
                        _buildSpecRow(context, Icons.access_time_rounded, 'Tiempo estimado', '${rug.estimatedDays} días hábiles'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom Action
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: PrimaryButton(
              text: 'Quiero algo parecido',
              icon: Icons.auto_awesome,
              width: double.infinity,
              onPressed: () {
                Navigator.of(context).pop();
                // Pre-fill creation draft
                final draft = CustomRugRequestModel(
                  prompt: 'Basado en el trabajo: ${rug.title}',
                  sizePreset: 'Personalizada',
                  woolType: 'Lana premium',
                );
                context.read<AppStateNotifier>().updateRugRequest(draft);

                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CreateRugWizardScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.terracotta),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.warmGray),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}
