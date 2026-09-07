import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_buttons.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _slides = [
    {
      'title': 'Convierte tus ideas en una alfombra',
      'subtitle': 'Sube cualquier imagen, dibujo o logotipo y nuestro equipo de tejedores la transformará en una pieza artesanal de lana única.',
      'image': 'https://images.unsplash.com/photo-1600121848594-d8644e57abab?q=80&w=800',
    },
    {
      'title': 'Personaliza cada detalle',
      'subtitle': 'Elige el tamaño exacto, la forma, densidad de la lana, bordes en relieve y tipo de soporte antideslizante a tu gusto.',
      'image': 'https://images.unsplash.com/photo-1579783902614-a3fb3927b675?q=80&w=800',
    },
    {
      'title': 'Recibe una pieza hecha especialmente para ti',
      'subtitle': 'Sigue el estado de tu pedido en tiempo real con fotos de avance hasta que llegue a las puertas de tu hogar.',
      'image': 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?q=80&w=800',
    },
  ];

  void _onGetStarted() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _onGetStarted,
                child: const Text('Omitir', style: TextStyle(color: AppColors.warmGray)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.network(
                            slide['image']!,
                            height: size.height * 0.38,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: size.height * 0.38,
                              color: AppColors.sand,
                              child: const Icon(Icons.palette_outlined, size: 60, color: AppColors.warmGray),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          slide['title']!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          slide['subtitle']!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 15,
                                height: 1.4,
                              ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? AppColors.terracotta : AppColors.sand,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  PrimaryButton(
                    text: _currentPage == _slides.length - 1 ? 'Comenzar' : 'Siguiente',
                    width: double.infinity,
                    onPressed: () {
                      if (_currentPage < _slides.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _onGetStarted();
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  SecondaryButton(
                    text: 'Ya tengo una cuenta',
                    width: double.infinity,
                    onPressed: _onGetStarted,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
