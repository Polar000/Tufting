import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_cards.dart';
import '../admin/admin_dashboard_screen.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateNotifier>();
    final user = appState.currentUser;
    final isDark = appState.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          if (user != null)
            IconButton(
              icon: Icon(
                user.isAdmin ? Icons.admin_panel_settings : Icons.admin_panel_settings_outlined,
                color: user.isAdmin ? AppColors.terracotta : AppColors.warmGray,
              ),
              tooltip: 'Modo Administrador',
              onPressed: () {
                appState.toggleAdminStatus(!user.isAdmin);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      user.isAdmin
                          ? 'Modo Administrador desactivado'
                          : 'Modo Administrador activado',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Info Header Card
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.terracotta,
                    backgroundImage: user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
                    child: user?.avatarUrl == null
                        ? Text(
                            user?.name.substring(0, 1).toUpperCase() ?? 'I',
                            style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Invitado',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email ?? 'Explorando catálogo',
                          style: const TextStyle(fontSize: 13, color: AppColors.warmGray),
                        ),
                        if (user?.isAdmin == true) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.terracotta.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Panel de Administrador Activo',
                              style: TextStyle(fontSize: 11, color: AppColors.terracotta, fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (user?.isAdmin == true) ...[
              AppCard(
                color: AppColors.terracotta.withValues(alpha: 0.12),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                  );
                },
                child: const Row(
                  children: [
                    Icon(Icons.dashboard_customize_rounded, color: AppColors.terracotta, size: 28),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ir al Panel Administrativo',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.terracotta),
                          ),
                          Text(
                            'Gestionar cotizaciones, pedidos e ingresos',
                            style: TextStyle(fontSize: 12, color: AppColors.warmGray),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: AppColors.terracotta),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            Text(
              'Ajustes de la Aplicación',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Theme Switcher Tile
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SwitchListTile(
                title: const Text('Modo Oscuro Artesanal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                subtitle: const Text('Colores optimizados para baja iluminación', style: TextStyle(fontSize: 12)),
                secondary: Icon(
                  isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                  color: AppColors.terracotta,
                ),
                value: isDark,
                activeColor: AppColors.terracotta,
                onChanged: (val) {
                  appState.toggleTheme(val);
                },
              ),
            ),
            const SizedBox(height: 12),

            // Account Options
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildOptionTile(
                    context,
                    Icons.location_on_outlined,
                    'Direcciones de Entrega',
                    'Gestiona las direcciones para envío',
                    () {},
                  ),
                  const Divider(height: 1),
                  _buildOptionTile(
                    context,
                    Icons.payment_outlined,
                    'Métodos de Pago Guardados',
                    'Tarjetas y cuentas para anticipos',
                    () {},
                  ),
                  const Divider(height: 1),
                  _buildOptionTile(
                    context,
                    Icons.help_outline_rounded,
                    'Ayuda & Preguntas Frecuentes',
                    'Proceso de tejido, cuidados de la lana',
                    () {},
                  ),
                  const Divider(height: 1),
                  _buildOptionTile(
                    context,
                    Icons.gavel_outlined,
                    'Términos y Condiciones',
                    'Garantía artesanal y devoluciones',
                    () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Logout Button
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                appState.logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout, size: 20),
              label: const SizedBox(
                width: double.infinity,
                child: Text('Cerrar Sesión', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.softBrown),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.warmGray),
      onTap: onTap,
    );
  }
}
