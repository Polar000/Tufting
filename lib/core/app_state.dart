import 'package:flutter/material.dart';
import '../shared/models/app_models.dart';
import '../shared/services/mock_data.dart';

class AppStateNotifier extends ChangeNotifier {
  // Theme Mode
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // Auth State
  UserModel? _currentUser;
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;
  UserModel? get currentUser => _currentUser;

  void login(String email, String password) {
    _currentUser = UserModel(
      id: 'u_101',
      name: 'Sofía Martínez',
      email: email,
      phone: '+502 5555 1234',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=400',
      isAdmin: email.contains('admin'),
    );
    _isLoggedIn = true;
    notifyListeners();
  }

  void loginAsGuest() {
    _currentUser = UserModel(
      id: 'u_guest',
      name: 'Invitado',
      email: 'invitado@lanatuft.com',
      phone: '',
      avatarUrl: null,
      isAdmin: false,
    );
    _isLoggedIn = false;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  void toggleAdminStatus(bool isAdmin) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(isAdmin: isAdmin);
      notifyListeners();
    }
  }

  // Custom Rug Creation Draft
  CustomRugRequestModel _currentRugRequest = const CustomRugRequestModel();
  CustomRugRequestModel get currentRugRequest => _currentRugRequest;

  void updateRugRequest(CustomRugRequestModel request) {
    _currentRugRequest = request;
    notifyListeners();
  }

  void resetRugRequest() {
    _currentRugRequest = const CustomRugRequestModel();
    notifyListeners();
  }

  // Orders
  List<OrderModel> _orders = List.from(MockData.mockOrders);
  List<OrderModel> get orders => _orders;

  OrderModel? createOrderFromCurrentRequest() {
    final newOrder = OrderModel(
      id: 'ORD-${(1000 + _orders.length + 1)}',
      date: DateTime.now(),
      title: _currentRugRequest.prompt.isNotEmpty
          ? _currentRugRequest.prompt
          : 'Alfombra Personalizada ${_currentRugRequest.shape}',
      imageUrl: _currentRugRequest.imagePath ??
          'https://images.unsplash.com/photo-1600121848594-d8644e57abab?q=80&w=800',
      requestDetails: _currentRugRequest,
      status: OrderStatus.solicitudRecibida,
      totalPrice: _currentRugRequest.calculateEstimatedPrice(),
      depositAmount: _currentRugRequest.calculateEstimatedPrice() / 2,
      remainingBalance: _currentRugRequest.calculateEstimatedPrice() / 2,
      isDepositPaid: false,
    );
    _orders.insert(0, newOrder);
    notifyListeners();
    return newOrder;
  }

  void payDepositForOrder(String orderId) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index].isDepositPaid = true;
      _orders[index].status = OrderStatus.disenoEnRevision;
      notifyListeners();
    }
  }

  void updateOrderStatusByAdmin(String orderId, OrderStatus newStatus, {double? updatedPrice, String? note}) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final order = _orders[index];
      order.status = newStatus;
      if (updatedPrice != null) {
        order.totalPrice = updatedPrice;
        order.depositAmount = updatedPrice / 2;
        order.remainingBalance = order.isDepositPaid ? updatedPrice / 2 : updatedPrice;
      }
      if (note != null) {
        order.adminNote = note;
      }
      notifyListeners();
    }
  }

  // Chat
  List<ChatMessageModel> _chatMessages = List.from(MockData.initialChatMessages);
  List<ChatMessageModel> get chatMessages => _chatMessages;

  void sendMessage(String text, {String? imageUrl}) {
    final msg = ChatMessageModel(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}',
      sender: 'user',
      text: text,
      imageUrl: imageUrl,
      timestamp: DateTime.now(),
    );
    _chatMessages.add(msg);
    notifyListeners();

    // Auto-reply mock
    Future.delayed(const Duration(seconds: 2), () {
      final autoReply = ChatMessageModel(
        id: 'm_${DateTime.now().millisecondsSinceEpoch + 1}',
        sender: 'company',
        text: '¡Gracias por escribirnos! Un maestro tejedor de LanaTuft revisará tu mensaje y responderá a la brevedad.',
        timestamp: DateTime.now(),
      );
      _chatMessages.add(autoReply);
      notifyListeners();
    });
  }

  // Notifications
  List<NotificationModel> _notifications = List.from(MockData.initialNotifications);
  List<NotificationModel> get notifications => _notifications;
  int get unreadNotificationsCount => _notifications.where((n) => !n.isRead).length;

  void markAllNotificationsAsRead() {
    for (var n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }
}
