import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/models/app_models.dart';
import '../../shared/services/mock_data.dart';
import '../../shared/widgets/app_cards.dart';
import 'rug_detail_modal.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Todos';
  String _sortBy = 'Popular';

  final List<String> _categories = [
    'Todos',
    'Animales',
    'Anime',
    'Gaming',
    'Logos',
    'Arte',
    'Minimalista',
    'Personalizados',
    'Decoración',
    'Otros',
  ];

  List<InspirationRugModel> get _filteredRugs {
    return MockData.inspirationRugs.where((rug) {
      final matchesSearch = _searchController.text.isEmpty ||
          rug.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          rug.description.toLowerCase().contains(_searchController.text.toLowerCase());

      final matchesCategory = _selectedCategory == 'Todos' || rug.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar Galería'),
      ),
      body: Column(
        children: [
          // Search & Filters bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Buscar alfombras, temas, logos...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.warmGray),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                PopupMenuButton<String>(
                  icon: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.sand.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.tune_rounded, color: AppColors.charcoal),
                  ),
                  onSelected: (val) {
                    setState(() {
                      _sortBy = val;
                    });
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'Popular', child: Text('Más Populares')),
                    const PopupMenuItem(value: 'PrecioAsc', child: Text('Precio: Menor a Mayor')),
                    const PopupMenuItem(value: 'PrecioDesc', child: Text('Precio: Mayor a Menor')),
                  ],
                ),
              ],
            ),
          ),

          // Categories Horizontal Bar
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = cat == _selectedCategory;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = cat;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.terracotta : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.terracotta : AppColors.sand,
                      ),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.charcoal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Grid Results
          Expanded(
            child: _filteredRugs.isEmpty
                ? const Center(
                    child: Text(
                      'No se encontraron alfombras con estos criterios',
                      style: TextStyle(color: AppColors.warmGray),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.76,
                    ),
                    itemCount: _filteredRugs.length,
                    itemBuilder: (context, index) {
                      final rug = _filteredRugs[index];
                      return RugCard(
                        rug: rug,
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => RugDetailModal(rug: rug),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
