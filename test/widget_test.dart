import 'package:flutter_test/flutter_test.dart';
import 'package:lana_tuft/shared/models/app_models.dart';

void main() {
  test('CustomRugRequestModel calculates price correctly', () {
    const request = CustomRugRequestModel(
      widthCm: 100,
      heightCm: 100,
      woolType: 'Lana premium',
      density: 'Alta',
      backing: 'Antideslizante',
      finish: 'Premium',
      selectedExtras: [
        RugExtraOption(
          id: 'ex_1',
          name: 'Relieve',
          description: 'Efecto 3D',
          extraPrice: 150.0,
        ),
      ],
    );

    // Calculation breakdown:
    // Base: 350
    // Area size (1m2 * 400): 400
    // Wool: 120
    // Density: 100
    // Backing: 75
    // Finish: 90
    // Extras: 150
    // Total = 350 + 400 + 120 + 100 + 75 + 90 + 150 = 1285.0
    expect(request.calculateEstimatedPrice(), equals(1285.0));
  });
}
