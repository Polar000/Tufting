class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? avatarUrl;
  final bool isAdmin;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatarUrl,
    this.isAdmin = false,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    bool? isAdmin,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}

class RugExtraOption {
  final String id;
  final String name;
  final String description;
  final double extraPrice;

  const RugExtraOption({
    required this.id,
    required this.name,
    required this.description,
    required this.extraPrice,
  });
}

class InspirationRugModel {
  final String id;
  final String title;
  final String category;
  final String sizeDescription;
  final double estimatedPrice;
  final String imageUrl;
  final String description;
  final String materialInfo;
  final int estimatedDays;

  const InspirationRugModel({
    required this.id,
    required this.title,
    required this.category,
    required this.sizeDescription,
    required this.estimatedPrice,
    required this.imageUrl,
    required this.description,
    required this.materialInfo,
    required this.estimatedDays,
  });
}

class CustomRugRequestModel {
  final String? imagePath;
  final String prompt;
  final String sizePreset; // 'Pequeña', 'Mediana', 'Grande', 'Personalizada'
  final double widthCm;
  final double heightCm;
  final String unit; // 'cm' or 'm'
  final String shape; // 'Rectangular', 'Cuadrada', 'Circular', 'Ovalada', 'Irregular', 'Personalizada'
  final String woolType; // 'Lana estándar', 'Lana premium', 'Mezcla premium'
  final String density; // 'Estándar', 'Alta', 'Extra alta'
  final String backing; // 'Fieltro', 'Antideslizante'
  final String finish; // 'Básico', 'Premium'
  final List<RugExtraOption> selectedExtras;

  const CustomRugRequestModel({
    this.imagePath,
    this.prompt = '',
    this.sizePreset = 'Mediana',
    this.widthCm = 80,
    this.heightCm = 100,
    this.unit = 'cm',
    this.shape = 'Rectangular',
    this.woolType = 'Lana estándar',
    this.density = 'Estándar',
    this.backing = 'Antideslizante',
    this.finish = 'Básico',
    this.selectedExtras = const [],
  });

  CustomRugRequestModel copyWith({
    String? imagePath,
    String? prompt,
    String? sizePreset,
    double? widthCm,
    double? heightCm,
    String? unit,
    String? shape,
    String? woolType,
    String? density,
    String? backing,
    String? finish,
    List<RugExtraOption>? selectedExtras,
  }) {
    return CustomRugRequestModel(
      imagePath: imagePath ?? this.imagePath,
      prompt: prompt ?? this.prompt,
      sizePreset: sizePreset ?? this.sizePreset,
      widthCm: widthCm ?? this.widthCm,
      heightCm: heightCm ?? this.heightCm,
      unit: unit ?? this.unit,
      shape: shape ?? this.shape,
      woolType: woolType ?? this.woolType,
      density: density ?? this.density,
      backing: backing ?? this.backing,
      finish: finish ?? this.finish,
      selectedExtras: selectedExtras ?? this.selectedExtras,
    );
  }

  double calculateEstimatedPrice() {
    double basePrice = 350.0;

    // Size multiplier
    double areaSqMeters = (widthCm / 100.0) * (heightCm / 100.0);
    double sizePrice = areaSqMeters * 400.0;
    if (sizePrice < 150.0) sizePrice = 150.0;

    // Wool multiplier
    double woolPrice = 0.0;
    if (woolType == 'Lana premium') woolPrice = 120.0;
    if (woolType == 'Mezcla premium') woolPrice = 80.0;

    // Density
    double densityPrice = 0.0;
    if (density == 'Alta') densityPrice = 100.0;
    if (density == 'Extra alta') densityPrice = 180.0;

    // Backing
    double backingPrice = backing == 'Antideslizante' ? 75.0 : 0.0;

    // Finish
    double finishPrice = finish == 'Premium' ? 90.0 : 0.0;

    // Extras
    double extrasPrice = selectedExtras.fold(0.0, (sum, item) => sum + item.extraPrice);

    return basePrice + sizePrice + woolPrice + densityPrice + backingPrice + finishPrice + extrasPrice;
  }
}

enum OrderStatus {
  solicitudRecibida('Solicitud recibida', 0),
  disenoEnRevision('Diseño en revisión', 1),
  disenoAprobado('Diseño aprobado', 2),
  enProduccion('En producción', 3),
  enAcabado('En acabado', 4),
  lista('Lista para entrega', 5),
  enCamino('En camino', 6),
  entregada('Entregada', 7);

  final String label;
  final int stepIndex;
  const OrderStatus(this.label, this.stepIndex);
}

class OrderModel {
  final String id;
  final DateTime date;
  final String title;
  final String imageUrl;
  final CustomRugRequestModel requestDetails;
  OrderStatus status;
  double totalPrice;
  double depositAmount;
  double remainingBalance;
  bool isDepositPaid;
  String? adminNote;

  OrderModel({
    required this.id,
    required this.date,
    required this.title,
    required this.imageUrl,
    required this.requestDetails,
    required this.status,
    required this.totalPrice,
    required this.depositAmount,
    required this.remainingBalance,
    this.isDepositPaid = false,
    this.adminNote,
  });
}

class ChatMessageModel {
  final String id;
  final String sender; // 'user' or 'company'
  final String text;
  final String? imageUrl;
  final DateTime timestamp;

  ChatMessageModel({
    required this.id,
    required this.sender,
    required this.text,
    this.imageUrl,
    required this.timestamp,
  });
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  bool isRead;
  final String? orderId;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.orderId,
  });
}
