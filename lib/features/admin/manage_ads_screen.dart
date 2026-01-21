import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../ads/ads_provider.dart';
import '../ads/ad_model.dart';

class ManageAdsScreen extends ConsumerWidget {
  const ManageAdsScreen({super.key});

  String _catLabel(AdCategory c) => switch (c) {
        AdCategory.elektronika => 'Elektronika',
        AdCategory.odeca => 'Odeća',
        AdCategory.namestaj => 'Nameštaj',
        AdCategory.usluge => 'Usluge',
        AdCategory.ostalo => 'Ostalo',
      };

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String adId,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Brisanje oglasa'),
        content: const Text('Da li želiš da obrišeš ovaj oglas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Ne'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Da'),
          ),
        ],
      ),
    );

    if (ok == true) {
      ref.read(adsProvider.notifier).deleteAdAsOwnerOrAdmin(adId);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ads = ref.watch(adsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Svi oglasi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
            onPressed: () {
            if (Navigator.of(context).canPop()) {
            context.pop();
          } else {
            context.go('/admin');
         }
     },  
        ),
      ),
      body: ads.isEmpty
          ? const Center(child: Text('Nema oglasa.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: ads.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final ad = ads[i]; 

                return Card(
                  child: ListTile(
                    title: Text(ad.title),
                    subtitle: Text(
                      '${_catLabel(ad.category)} • ${ad.price.toStringAsFixed(0)} €\n${ad.ownerName} • ${ad.city}',
                    ),
                    isThreeLine: true,
                    onTap: () => context.go('/ad/${ad.id}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Izmeni',
                          icon: const Icon(Icons.edit),
                          onPressed: () => context.push('/edit/${ad.id}'),
                        ),
                        IconButton(
                          tooltip: 'Obriši',
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(context, ref, ad.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
