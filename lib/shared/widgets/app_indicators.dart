import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../models/app_models.dart';

class PriceSummary extends StatelessWidget {
  final CustomRugRequestModel request;

  const PriceSummary({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: 'Q', decimalDigits: 2);

    double areaSqMeters = (request.widthCm / 100.0) * (request.heightCm / 100.0);
    double sizePrice = areaSqMeters * 400.0;
    if (sizePrice < 150.0) sizePrice = 150.0;

    double woolPrice = 0.0;
    if (request.woolType == 'Lana premium') woolPrice = 120.0;
    if (request.woolType == 'Mezcla premium') woolPrice = 80.0;

    double densityPrice = 0.0;
    if (request.density == 'Alta') densityPrice = 100.0;
    if (request.density == 'Extra alta') densityPrice = 180.0;

    double backingPrice = request.backing == 'Antideslizante' ? 75.0 : 0.0;
    double finishPrice = request.finish == 'Premium' ? 90.0 : 0.0;

    double totalPrice = request.calculateEstimatedPrice();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.sand.withValues(alpha: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Resumen de Estimación',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.oliveGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Transparente',
                  style: TextStyle(
                    color: AppColors.oliveGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          _buildItem(context, 'Base de diseño tufting', currencyFormat.format(350.00)),
          _buildItem(context, 'Tamaño (${request.widthCm.toInt()} x ${request.heightCm.toInt()} ${request.unit})', currencyFormat.format(sizePrice)),
          if (woolPrice > 0)
            _buildItem(context, 'Material: ${request.woolType}', currencyFormat.format(woolPrice)),
          if (densityPrice > 0)
            _buildItem(context, 'Densidad: ${request.density}', currencyFormat.format(densityPrice)),
          if (backingPrice > 0)
            _buildItem(context, 'Dorso: ${request.backing}', currencyFormat.format(backingPrice)),
          if (finishPrice > 0)
            _buildItem(context, 'Acabado: ${request.finish}', currencyFormat.format(finishPrice)),

          for (var extra in request.selectedExtras)
            _buildItem(context, 'Extra: ${extra.name}', currencyFormat.format(extra.extraPrice)),

          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TOTAL ESTIMADO',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.warmGray,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    currencyFormat.format(totalPrice),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Anticipo (50%)',
                    style: TextStyle(fontSize: 12, color: AppColors.warmGray),
                  ),
                  Text(
                    currencyFormat.format(totalPrice / 2),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.sand.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: AppColors.warmGray),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'El precio final se confirmará tras la revisión técnica del diseño por el artesano.',
                    style: TextStyle(fontSize: 11, color: AppColors.warmGray),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, String label, String price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                  ),
            ),
          ),
          Text(
            price,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepTitles;

  const StepIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 5,
    required this.stepTitles,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PASO ${currentStep + 1} DE $totalSteps',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.terracotta,
                letterSpacing: 1,
              ),
            ),
            Text(
              stepTitles[currentStep],
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(totalSteps, (index) {
            final isActive = index <= currentStep;
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: index == totalSteps - 1 ? 0 : 6),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.terracotta : AppColors.sand,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class OrderTimeline extends StatelessWidget {
  final OrderStatus currentStatus;

  const OrderTimeline({super.key, required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    final steps = OrderStatus.values;
    final currentIndex = currentStatus.stepIndex;

    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isCompleted = index <= currentIndex;
        final isCurrent = index == currentIndex;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? (isCurrent ? AppColors.terracotta : AppColors.oliveGreen)
                        : AppColors.sand,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : Text(
                            '${index + 1}',
                            style: const TextStyle(fontSize: 11, color: AppColors.warmGray),
                          ),
                  ),
                ),
                if (index < steps.length - 1)
                  Container(
                    width: 2,
                    height: 28,
                    color: index < currentIndex ? AppColors.oliveGreen : AppColors.sand,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  step.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    color: isCompleted ? Theme.of(context).textTheme.bodyLarge?.color : AppColors.warmGray,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.sand,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: AppColors.softBrown),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (buttonText != null && onButtonPressed != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onButtonPressed,
              child: Text(buttonText!),
            ),
          ]
        ],
      ),
    );
  }
}
