import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/models/app_models.dart';
import '../../shared/services/mock_data.dart';
import '../../shared/widgets/app_buttons.dart';
import '../../shared/widgets/app_indicators.dart';
import '../navigation/main_navigation_shell.dart';
import '../orders/order_detail_screen.dart';

class CreateRugWizardScreen extends StatefulWidget {
  const CreateRugWizardScreen({super.key});

  @override
  State<CreateRugWizardScreen> createState() => _CreateRugWizardScreenState();
}

class _CreateRugWizardScreenState extends State<CreateRugWizardScreen> {
  int _currentStep = 0;
  final List<String> _stepTitles = [
    'Tu Diseño',
    'Tamaño',
    'Forma',
    'Material & Acabado',
    'Extras',
  ];

  // Step 1 State
  final TextEditingController _promptController = TextEditingController();
  String? _selectedImagePath;

  // Step 2 State
  String _selectedSizePreset = 'Mediana';
  final TextEditingController _widthController = TextEditingController(text: '80');
  final TextEditingController _heightController = TextEditingController(text: '100');
  String _unit = 'cm';

  // Step 3 State
  String _selectedShape = 'Rectangular';

  // Step 4 State
  String _selectedWool = 'Lana estándar';
  String _selectedDensity = 'Estándar';
  String _selectedBacking = 'Antideslizante';
  String _selectedFinish = 'Básico';

  // Step 5 State
  final List<RugExtraOption> _selectedExtras = [];

  @override
  void initState() {
    super.initState();
    final draft = context.read<AppStateNotifier>().currentRugRequest;
    _promptController.text = draft.prompt;
    _selectedImagePath = draft.imagePath;
    _selectedSizePreset = draft.sizePreset;
    _widthController.text = draft.widthCm.toInt().toString();
    _heightController.text = draft.heightCm.toInt().toString();
    _unit = draft.unit;
    _selectedShape = draft.shape;
    _selectedWool = draft.woolType;
    _selectedDensity = draft.density;
    _selectedBacking = draft.backing;
    _selectedFinish = draft.finish;
    _selectedExtras.addAll(draft.selectedExtras);
  }

  void _syncStateToNotifier() {
    final double width = double.tryParse(_widthController.text) ?? 80.0;
    final double height = double.tryParse(_heightController.text) ?? 100.0;

    final updated = CustomRugRequestModel(
      imagePath: _selectedImagePath,
      prompt: _promptController.text,
      sizePreset: _selectedSizePreset,
      widthCm: width,
      heightCm: height,
      unit: _unit,
      shape: _selectedShape,
      woolType: _selectedWool,
      density: _selectedDensity,
      backing: _selectedBacking,
      finish: _selectedFinish,
      selectedExtras: List.from(_selectedExtras),
    );

    context.read<AppStateNotifier>().updateRugRequest(updated);
  }

  void _nextStep() {
    _syncStateToNotifier();
    if (_currentStep < _stepTitles.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      // Go to Product Preview & Realtime Calculation screen
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const RugPreviewScreen()),
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = context.watch<AppStateNotifier>().currentRugRequest;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diseñar Alfombra'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _prevStep,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: StepIndicator(
                currentStep: _currentStep,
                stepTitles: _stepTitles,
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildCurrentStepWidget(),
              ),
            ),
            // Bottom Sticky Bar with Live Calculated Price & Next button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Precio Estimado',
                        style: TextStyle(fontSize: 12, color: AppColors.warmGray),
                      ),
                      Text(
                        'Q${draft.calculateEstimatedPrice().toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.terracotta,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  PrimaryButton(
                    text: _currentStep == _stepTitles.length - 1 ? 'Ver Resumen' : 'Siguiente',
                    icon: _currentStep == _stepTitles.length - 1 ? Icons.visibility : Icons.arrow_forward,
                    onPressed: _nextStep,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStepWidget() {
    switch (_currentStep) {
      case 0:
        return _buildStep1Design();
      case 1:
        return _buildStep2Size();
      case 2:
        return _buildStep3Shape();
      case 3:
        return _buildStep4Material();
      case 4:
        return _buildStep5Extras();
      default:
        return Container();
    }
  }

  // STEP 1: DESIGN & PROMPT
  Widget _buildStep1Design() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Muéstranos tu idea',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          'Sube una imagen de referencia, boceto o logotipo que quieras convertir en alfombra tufting.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),

        // Image Picker Area
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedImagePath = 'https://images.unsplash.com/photo-1600121848594-d8644e57abab?q=80&w=800';
            });
            _syncStateToNotifier();
          },
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.sand.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.sand,
                style: BorderStyle.solid,
                width: 1.5,
              ),
            ),
            child: _selectedImagePath != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(_selectedImagePath!, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: CircleAvatar(
                          backgroundColor: Colors.black.withValues(alpha: 0.6),
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white, size: 18),
                            onPressed: () {
                              setState(() {
                                _selectedImagePath = null;
                              });
                              _syncStateToNotifier();
                            },
                          ),
                        ),
                      ),
                    ],
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_outlined, size: 44, color: AppColors.terracotta),
                      SizedBox(height: 12),
                      Text(
                        'Toca para subir o tomar foto de referencia',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.charcoal),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Formatos aceptados: PNG, JPG (Hasta 10MB)',
                        style: TextStyle(fontSize: 12, color: AppColors.warmGray),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 28),

        Text(
          'Cuéntanos cómo quieres tu alfombra',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _promptController,
          maxLines: 4,
          onChanged: (_) => _syncStateToNotifier(),
          decoration: const InputDecoration(
            hintText: 'Ej. "Quiero el logo de mi negocio con fondo negro y bordes de lana en relieve blanco..."',
          ),
        ),
      ],
    );
  }

  // STEP 2: SIZE
  Widget _buildStep2Size() {
    final presets = [
      {'name': 'Pequeña', 'desc': '50 x 50 cm', 'w': 50, 'h': 50},
      {'name': 'Mediana', 'desc': '80 x 100 cm', 'w': 80, 'h': 100},
      {'name': 'Grande', 'desc': '120 x 150 cm', 'w': 120, 'h': 150},
      {'name': 'Personalizada', 'desc': 'Medida exacta', 'w': 100, 'h': 100},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecciona las dimensiones',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          'Elige un tamaño estándar o escribe el ancho y alto exacto que necesitas.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: presets.map((p) {
            final isSelected = p['name'] == _selectedSizePreset;
            return ChoiceChip(
              label: Text('${p['name']} (${p['desc']})'),
              selected: isSelected,
              selectedColor: AppColors.terracotta.withValues(alpha: 0.2),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedSizePreset = p['name'] as String;
                    if (_selectedSizePreset != 'Personalizada') {
                      _widthController.text = p['w'].toString();
                      _heightController.text = p['h'].toString();
                    }
                  });
                  _syncStateToNotifier();
                }
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _widthController,
                keyboardType: TextInputType.number,
                onChanged: (_) => _syncStateToNotifier(),
                decoration: const InputDecoration(
                  labelText: 'Ancho',
                  suffixText: 'cm',
                ),
              ),
            ),
            const SizedBox(width: 16),
            const Text('X', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.warmGray)),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                onChanged: (_) => _syncStateToNotifier(),
                decoration: const InputDecoration(
                  labelText: 'Alto',
                  suffixText: 'cm',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Visual Proportion Ratio Mockup
        Center(
          child: Column(
            children: [
              const Text('Previsualización de proporción:', style: TextStyle(fontSize: 12, color: AppColors.warmGray)),
              const SizedBox(height: 12),
              Container(
                width: 140,
                height: (double.tryParse(_heightController.text) ?? 100) /
                    (double.tryParse(_widthController.text) ?? 80) *
                    100,
                constraints: const BoxConstraints(minHeight: 60, maxHeight: 180),
                decoration: BoxDecoration(
                  color: AppColors.sand,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.terracotta, width: 2),
                ),
                child: Center(
                  child: Text(
                    '${_widthController.text} x ${_heightController.text} cm',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.charcoal),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // STEP 3: SHAPE
  Widget _buildStep3Shape() {
    final shapes = [
      {'name': 'Rectangular', 'icon': Icons.crop_landscape_rounded},
      {'name': 'Cuadrada', 'icon': Icons.crop_square_rounded},
      {'name': 'Circular', 'icon': Icons.circle_outlined},
      {'name': 'Ovalada', 'icon': Icons.egg_outlined},
      {'name': 'Irregular', 'icon': Icons.gesture},
      {'name': 'Personalizada', 'icon': Icons.polyline},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecciona la forma',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          'La silueta final recortada a mano que tendrá la alfombra.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 2.2,
          ),
          itemCount: shapes.length,
          itemBuilder: (context, index) {
            final item = shapes[index];
            final isSelected = item['name'] == _selectedShape;

            return InkWell(
              onTap: () {
                setState(() {
                  _selectedShape = item['name'] as String;
                });
                _syncStateToNotifier();
              },
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.terracotta.withValues(alpha: 0.15)
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.terracotta : AppColors.sand,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      color: isSelected ? AppColors.terracotta : AppColors.warmGray,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item['name'] as String,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppColors.terracotta : AppColors.charcoal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // STEP 4: MATERIAL & FINISH
  Widget _buildStep4Material() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Material y Acabado',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          'Elige la calidad de la lana, la densidad de hilos y el material de la parte posterior.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),

        // Wool Type
        _buildSectionHeader('Tipo de Lana'),
        Wrap(
          spacing: 10,
          children: ['Lana estándar', 'Lana premium', 'Mezcla premium'].map((w) {
            final isSelected = w == _selectedWool;
            return ChoiceChip(
              label: Text(w),
              selected: isSelected,
              onSelected: (sel) {
                if (sel) {
                  setState(() => _selectedWool = w);
                  _syncStateToNotifier();
                }
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // Density
        _buildSectionHeader('Densidad de Tejido'),
        Wrap(
          spacing: 10,
          children: ['Estándar', 'Alta', 'Extra alta'].map((d) {
            final isSelected = d == _selectedDensity;
            return ChoiceChip(
              label: Text(d),
              selected: isSelected,
              onSelected: (sel) {
                if (sel) {
                  setState(() => _selectedDensity = d);
                  _syncStateToNotifier();
                }
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // Backing
        _buildSectionHeader('Parte Posterior (Dorso)'),
        Wrap(
          spacing: 10,
          children: ['Fieltro', 'Antideslizante'].map((b) {
            final isSelected = b == _selectedBacking;
            return ChoiceChip(
              label: Text(b),
              selected: isSelected,
              onSelected: (sel) {
                if (sel) {
                  setState(() => _selectedBacking = b);
                  _syncStateToNotifier();
                }
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // Finish
        _buildSectionHeader('Estilo de Acabado'),
        Wrap(
          spacing: 10,
          children: ['Básico', 'Premium'].map((f) {
            final isSelected = f == _selectedFinish;
            return ChoiceChip(
              label: Text(f),
              selected: isSelected,
              onSelected: (sel) {
                if (sel) {
                  setState(() => _selectedFinish = f);
                  _syncStateToNotifier();
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // STEP 5: EXTRAS
  Widget _buildStep5Extras() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Opciones Especiales y Extras',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          'Añade detalles artesanales de lujo a tu alfombra.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),

        Column(
          children: MockData.availableExtras.map((extra) {
            final isSelected = _selectedExtras.any((e) => e.id == extra.id);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.terracotta : AppColors.sand,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: CheckboxListTile(
                value: isSelected,
                activeColor: AppColors.terracotta,
                title: Text(
                  extra.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                subtitle: Text(
                  '${extra.description}\n+ Q${extra.extraPrice.toInt()}',
                  style: const TextStyle(fontSize: 12, height: 1.3),
                ),
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      _selectedExtras.add(extra);
                    } else {
                      _selectedExtras.removeWhere((e) => e.id == extra.id);
                    }
                  });
                  _syncStateToNotifier();
                },
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.softBrown),
      ),
    );
  }
}

// PRODUCT PREVIEW & QUOTE SUMMARY
class RugPreviewScreen extends StatelessWidget {
  const RugPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateNotifier>();
    final request = appState.currentRugRequest;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen del Pedido'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Mockup Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.sand.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.sand),
              ),
              child: Column(
                children: [
                  const Text(
                    'MOCKUP VISUAL DE ALFOMBRA',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppColors.warmGray),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      request.imagePath ?? 'https://images.unsplash.com/photo-1600121848594-d8644e57abab?q=80&w=800',
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Chip(label: Text('Forma: ${request.shape}')),
                      const SizedBox(width: 8),
                      Chip(label: Text('${request.widthCm.toInt()}x${request.heightCm.toInt()} cm')),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            PriceSummary(request: request),
            const SizedBox(height: 28),

            PrimaryButton(
              text: 'Solicitar Cotización y Confirmar',
              icon: Icons.send_rounded,
              width: double.infinity,
              onPressed: () {
                final newOrder = appState.createOrderFromCurrentRequest();
                if (newOrder != null) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => ReserveAndPayScreen(order: newOrder),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// RESERVE & PAY DEPOSIT
class ReserveAndPayScreen extends StatefulWidget {
  final OrderModel order;

  const ReserveAndPayScreen({super.key, required this.order});

  @override
  State<ReserveAndPayScreen> createState() => _ReserveAndPayScreenState();
}

class _ReserveAndPayScreenState extends State<ReserveAndPayScreen> {
  String _selectedMethod = 'Tarjeta';
  bool _isProcessing = false;

  void _processPayment() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      context.read<AppStateNotifier>().payDepositForOrder(widget.order.id);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OrderSuccessConfirmationScreen(order: widget.order),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reserva tu Diseño')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.terracotta.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.workspace_premium, color: AppColors.terracotta, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Para comenzar a fabricar tu pieza artesanal requerimos la confirmación mediante el pago del anticipo.',
                      style: TextStyle(fontSize: 13, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Desglose del Pago',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.sand),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Monto Total:'),
                      Text('Q${widget.order.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Anticipo a Pagar Hoy (50%):', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.terracotta)),
                      Text('Q${widget.order.depositAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.terracotta)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Saldo Pendiente contra Entrega:', style: TextStyle(fontSize: 12, color: AppColors.warmGray)),
                      Text('Q${widget.order.remainingBalance.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: AppColors.warmGray)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Método de Pago',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            RadioListTile<String>(
              value: 'Tarjeta',
              groupValue: _selectedMethod,
              title: const Text('Tarjeta de Crédito / Débito'),
              subtitle: const Text('Procesado seguro de forma cifrada'),
              secondary: const Icon(Icons.credit_card),
              onChanged: (val) => setState(() => _selectedMethod = val!),
            ),
            RadioListTile<String>(
              value: 'Transferencia',
              groupValue: _selectedMethod,
              title: const Text('Transferencia Bancaria Directa'),
              subtitle: const Text('Depósito en cuenta BI / G&T'),
              secondary: const Icon(Icons.account_balance),
              onChanged: (val) => setState(() => _selectedMethod = val!),
            ),
            const SizedBox(height: 28),

            PrimaryButton(
              text: 'Pagar Anticipo Q${widget.order.depositAmount.toStringAsFixed(2)}',
              icon: Icons.lock,
              width: double.infinity,
              isLoading: _isProcessing,
              onPressed: _processPayment,
            ),
          ],
        ),
      ),
    );
  }
}

// SUCCESS CONFIRMATION
class OrderSuccessConfirmationScreen extends StatelessWidget {
  final OrderModel order;

  const OrderSuccessConfirmationScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: AppColors.oliveGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 64),
              ),
              const SizedBox(height: 24),
              Text(
                '¡Tu alfombra está en camino!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Recibimos tu solicitud y pago de anticipo. Nuestro artesano maestro comenzará a revisar tu diseño.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 28),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.sand.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Número de Pedido:'),
                        Text(order.id, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Anticipo Pagado:'),
                        Text('Q${order.depositAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.oliveGreen)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              PrimaryButton(
                text: 'Ver mi pedido',
                width: double.infinity,
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const MainNavigationShell(initialIndex: 3)),
                    (route) => false,
                  );
                },
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                text: 'Volver al inicio',
                width: double.infinity,
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const MainNavigationShell(initialIndex: 0)),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
