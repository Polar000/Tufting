import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_buttons.dart';
import '../navigation/main_navigation_shell.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _submitRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        context.read<AppStateNotifier>().login(
              _emailController.text.trim(),
              _passwordController.text.trim(),
            );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainNavigationShell()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Únete a LanaTuft',
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Crea alfombras artesanales únicas con los tejedores expertos.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 28),
                Text('Nombre completo', style: theme.textTheme.titleMedium?.copyWith(fontSize: 14)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'María García',
                    prefixIcon: Icon(Icons.person_outline, color: AppColors.warmGray),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa tu nombre' : null,
                ),
                const SizedBox(height: 16),
                Text('Correo electrónico', style: theme.textTheme.titleMedium?.copyWith(fontSize: 14)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'maria@ejemplo.com',
                    prefixIcon: Icon(Icons.email_outlined, color: AppColors.warmGray),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Ingresa tu correo';
                    if (!val.contains('@')) return 'Correo no válido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text('Teléfono de contacto', style: theme.textTheme.titleMedium?.copyWith(fontSize: 14)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: '+502 5555 0000',
                    prefixIcon: Icon(Icons.phone_outlined, color: AppColors.warmGray),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Ingresa tu número telefónico' : null,
                ),
                const SizedBox(height: 16),
                Text('Contraseña', style: theme.textTheme.titleMedium?.copyWith(fontSize: 14)),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: Icon(Icons.lock_outline, color: AppColors.warmGray),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Crea una contraseña';
                    if (val.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  text: 'Crear mi cuenta',
                  width: double.infinity,
                  isLoading: _isLoading,
                  onPressed: _submitRegister,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
