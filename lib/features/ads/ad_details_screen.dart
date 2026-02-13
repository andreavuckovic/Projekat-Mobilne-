import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'ads_provider.dart';
import 'ad_model.dart';

import '../currency/currency_provider.dart';
import '../currency/currency_format.dart';

class AdDetailsScreen extends ConsumerStatefulWidget {
  final String adId;
  const AdDetailsScreen({super.key, required this.adId});

  @override
  ConsumerState<AdDetailsScreen> createState() => _AdDetailsScreenState();
}

class _AdDetailsScreenState extends ConsumerState<AdDetailsScreen> {
  int _page = 0;

  String _catLabel(AdCategory c) => switch (c) {
        AdCategory.elektronika => 'Electronics',
        AdCategory.odeca => 'Clothing',
        AdCategory.namestaj => 'Furniture', 
        AdCategory.usluge => 'Services',
        AdCategory.ostalo => 'Other',
      };

  @override
  Widget build(BuildContext context) {
    final adsAsync = ref.watch(adsStreamProvider);
    final currency = ref.watch(currencyProvider);

    return adsAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Greška: $e')),
      ),
      data: (ads) {
        final ad = ads.where((a) => a.id == widget.adId).firstOrNull;

        if (ad == null) {
          return const Scaffold(
            body: Center(child: Text('Oglas nije pronađen.')),
          );
        }

        final imagesAsync = ref.watch(adImagesProvider(ad.id));
        final theme = Theme.of(context);

        return Scaffold(
          appBar: AppBar(
            title: Text(ad.title),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/'),
            ),
          ),
          body: ListView(
            children: [
              imagesAsync.when(
                loading: () => SizedBox(
                  height: 300,
                  child: Container(
                    alignment: Alignment.center,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const CircularProgressIndicator(),
                  ),
                ),
                error: (e, _) => Container(
                  height: 240,
                  alignment: Alignment.center,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Text('Greška: $e'),
                ),
                data: (List<Uint8List> images) {
                  if (images.isEmpty) {
                    return Container(
                      height: 240,
                      alignment: Alignment.center,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.image_not_supported, size: 60),
                    );
                  }

                  return Stack(
                    children: [
                      SizedBox(
                        height: 300,
                        child: PageView.builder(
                          itemCount: images.length,
                          onPageChanged: (i) => setState(() => _page = i),
                          itemBuilder: (_, i) => Image.memory(
                            images[i],
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        bottom: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: Colors.black.withOpacity(0.55),
                          ),
                          child: Text(
                            '${_page + 1}/${images.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          formatPrice(ad.price, currency),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: theme.colorScheme.surfaceContainerHighest,
                          ),
                          child: Text(
                            _catLabel(ad.category),
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      ad.description,
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.35),
                    ),
                    const SizedBox(height: 18),
                    _InfoTile(
                      icon: Icons.person_outline,
                      label: 'Postavio',
                      value: ad.ownerName,
                    ),
                    const SizedBox(height: 10),
                    _InfoTile(
                      icon: Icons.location_on_outlined,
                      label: 'Grad',
                      value: ad.city,
                    ),
                    const SizedBox(height: 10),
                    _InfoTile(
                      icon: Icons.call_outlined,
                      label: 'Kontakt',
                      value: ad.contact,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.surfaceContainerHighest,
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 10),
          Text(
            '$label:',
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
