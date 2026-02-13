import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'ads_provider.dart';
import 'ad_model.dart';
import 'category_filter_provider.dart';

import '../currency/currency_provider.dart';
import '../currency/currency_format.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _catLabel(AdCategory c) => switch (c) {
        AdCategory.elektronika => 'Electronics',
        AdCategory.odeca => 'Clothing',
        AdCategory.namestaj => 'Furniture',
        AdCategory.usluge => 'Services',
        AdCategory.ostalo => 'Other', 
      };

  IconData _catIcon(AdCategory c) => switch (c) {
        AdCategory.elektronika => Icons.phone_iphone,
        AdCategory.odeca => Icons.checkroom,
        AdCategory.namestaj => Icons.chair_alt,
        AdCategory.usluge => Icons.handyman,
        AdCategory.ostalo => Icons.category,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adsAsync = ref.watch(adsStreamProvider);
    final selectedCategory = ref.watch(categoryFilterProvider);
    final currency = ref.watch(currencyProvider);

    return adsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Greška: $e')),
      data: (ads) {
        final filteredAds = selectedCategory == null
            ? ads
            : ads.where((a) => a.category == selectedCategory).toList();

        return Column(
          children: [
            SizedBox(
              height: 56,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  ChoiceChip(
                    label: const Text('Sve'),
                    selected: selectedCategory == null,
                    onSelected: (_) =>
                        ref.read(categoryFilterProvider.notifier).setCategory(null),
                  ),
                  const SizedBox(width: 8),
                  ...AdCategory.values.map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        avatar: Icon(_catIcon(c), size: 18),
                        label: Text(_catLabel(c)),
                        selected: selectedCategory == c,
                        onSelected: (_) =>
                            ref.read(categoryFilterProvider.notifier).setCategory(c),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filteredAds.isEmpty
                  ? const Center(child: Text('Nema oglasa u ovoj kategoriji.'))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: filteredAds.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final ad = filteredAds[i];
                        return _AdCard(
                          adId: ad.id,
                          title: ad.title,
                          priceText: formatPrice(ad.price, currency),
                          city: ad.city,
                          categoryLabel: _catLabel(ad.category),
                          onTap: () => context.go('/ad/${ad.id}'),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _AdCard extends ConsumerWidget {
  final String adId;
  final String title;
  final String priceText;
  final String city;
  final String categoryLabel;
  final VoidCallback onTap;

  const _AdCard({
    required this.adId,
    required this.title,
    required this.priceText,
    required this.city,
    required this.categoryLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final thumbAsync = ref.watch(adThumbProvider(adId));

    Widget imageWidget = Container(
      color: theme.colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported, size: 44),
    );

    thumbAsync.whenData((bytes) {
      if (bytes != null) {
        imageWidget = Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: double.infinity,
        );
      }
    });

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              blurRadius: 14,
              offset: const Offset(0, 6),
              color: Colors.black.withOpacity(0.08),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: thumbAsync.when(
                  loading: () => imageWidget,
                  error: (_, __) => imageWidget,
                  data: (Uint8List? bytes) => bytes == null
                      ? imageWidget
                      : Image.memory(bytes, fit: BoxFit.cover, width: double.infinity),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        priceText,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ), 
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: theme.colorScheme.surfaceContainerHighest,
                        ),
                        child: Text(
                          categoryLabel,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ), 
                        ), 
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.location_on_outlined, size: 18),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          city,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
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
