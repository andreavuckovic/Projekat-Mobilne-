import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ads_provider.dart';
import 'ad_model.dart';
import 'category_filter_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _catLabel(AdCategory c) => switch (c) {
        AdCategory.elektronika => 'Elektronika',
        AdCategory.odeca => 'Odeća',
        AdCategory.namestaj => 'Nameštaj',
        AdCategory.usluge => 'Usluge',
        AdCategory.ostalo => 'Ostalo',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ads = ref.watch(adsProvider);
    final selectedCategory = ref.watch(categoryFilterProvider);

    final filteredAds = selectedCategory == null
        ? ads
        : ads.where((a) => a.category == selectedCategory).toList();

    return Column(
      children: [
        // KATEGORIJE
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

        // LISTA OGLASA
        Expanded(
          child: filteredAds.isEmpty
              ? const Center(child: Text('Nema oglasa u ovoj kategoriji.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredAds.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final ad = filteredAds[i];
                    return Card(
                      child: ListTile(
                        title: Text(ad.title),
                        subtitle: Text(
                          '${_catLabel(ad.category)} • ${ad.price.toStringAsFixed(0)} €',
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
