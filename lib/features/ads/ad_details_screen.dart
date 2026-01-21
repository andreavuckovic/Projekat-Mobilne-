import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ads_provider.dart';
import 'ad_model.dart';

class AdDetailsScreen extends ConsumerWidget {
  final String adId;
  const AdDetailsScreen({super.key, required this.adId});

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
    final ad = ads.where((a) => a.id == adId).firstOrNull;

    if (ad == null) { 
      return const Scaffold(
        body: Center(child: Text('Oglas nije pronađen.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(ad.title)),
      
      body: ListView(
        children: [ 
          if (ad.images.isNotEmpty)
            SizedBox(
              height: 280,
              child: PageView.builder(
                itemCount: ad.images.length,
                itemBuilder: (_, i) => Image.memory(ad.images[i], fit: BoxFit.cover),
              ),
            )
          else
            Container(
              height: 200,
              alignment: Alignment.center,
              child: const Icon(Icons.image_not_supported, size: 60),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${ad.price.toStringAsFixed(0)} €',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                Chip(label: Text(_catLabel(ad.category))),
                const SizedBox(height: 12),
                Text(
                  ad.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
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
