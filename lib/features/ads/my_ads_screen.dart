import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_provider.dart';
import 'ads_provider.dart';
import 'ad_model.dart';

class MyAdsScreen extends ConsumerWidget {
  const MyAdsScreen({super.key});

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
    final user = ref.watch(authProvider).user;
    final ads = ref.watch(adsProvider);

    if (user == null) {
      return const Center(child: Text('Nisi ulogovana.'));
    }

    final myAds = ads.where((a) => a.ownerId == user.id).toList();

    if (myAds.isEmpty) {
      return const Center(child: Text('Još nemaš nijedan oglas.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: myAds.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final ad = myAds[i];

        return Card(
          child: ListTile(
            title: Text(ad.title),
            subtitle: Text(
              '${_catLabel(ad.category)} • ${ad.price.toStringAsFixed(0)} €',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Izmeni',
                  icon: const Icon(Icons.edit),
                  onPressed: () => context.go('/edit/${ad.id}'),
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
    );
  }
}
