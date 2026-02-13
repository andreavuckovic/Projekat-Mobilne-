import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../ads/ads_provider.dart';
import '../ads/ad_model.dart';

class ManageAdsScreen extends ConsumerWidget {
  const ManageAdsScreen({super.key});

  String _catLabel(AdCategory c) => switch (c) {
        AdCategory.elektronika => 'Electronics',
        AdCategory.odeca => 'Clothing', 
        AdCategory.namestaj => 'Furniture',
        AdCategory.usluge => 'Services',
        AdCategory.ostalo => 'Other', 
      };

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Ad ad,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete ad'),
        content: const Text('Are you sure ypu want to delete this ad?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Yes'), 
          ),
        ],
      ),
    ); 

    if (ok == true) {
      await ref.read(adsActionsProvider.notifier).deleteAdAsOwnerOrAdmin(ad);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adsAsync = ref.watch(adsStreamProvider);

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
      body: adsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Greška: $e')),
        data: (ads) {
          if (ads.isEmpty) return const Center(child: Text('Nema oglasa.'));

          return ListView.separated(
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
                        onPressed: () => _confirmDelete(context, ref, ad),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
