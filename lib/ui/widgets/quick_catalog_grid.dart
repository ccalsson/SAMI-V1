import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sami_app/core/utils/formatters.dart';
import 'package:sami_app/data/models/product.dart';
import 'package:sami_app/state/catalog_provider.dart';

class QuickCatalogGrid extends StatelessWidget {
  const QuickCatalogGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CatalogProvider>(
      builder: (context, catalog, _) {
        final products = catalog.products;
        if (catalog.isLoading && products.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        final screenWidth = MediaQuery.of(context).size.width;
        final crossAxisCount = screenWidth >= 900 ? 3 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: crossAxisCount == 3 ? 1 : 1.1,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            final isSelected = catalog.selectedProduct?.id == product.id;
            return _CatalogTile(product: product, isSelected: isSelected);
          },
        );
      },
    );
  }
}

class _CatalogTile extends StatelessWidget {
  const _CatalogTile({required this.product, required this.isSelected});

  final Product product;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.read<CatalogProvider>().selectProduct(product);
      },
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(product.emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 6),
              Text(
                product.name,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                formatCurrency(product.pricePerKg),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (isSelected)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'Seleccionado',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
