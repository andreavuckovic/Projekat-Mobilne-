import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_provider.dart';
import '../currency/currency_format.dart';
import '../currency/currency_provider.dart';
import 'ad_model.dart';
import 'ads_provider.dart';

class MyAdsScreen extends ConsumerWidget {
  const MyAdsScreen({super.key});

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
        content: const Text('Are you sure you want to delete this ad?'),
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
    final uid = ref.watch(authProvider.select((s) => s.user?.id));
    final currency = ref.watch(currencyProvider);

    if (uid == null) {
      return const Center(child: Text('Nisi ulogovana.'));
    }

    final myAdsAsync = ref.watch(myAdsStreamProvider(uid));

    return myAdsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Greška: $e')),
      data: (myAds) {
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
                  '${_catLabel(ad.category)} • ${formatPrice(ad.price, currency)}',
                ),
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
    );
  }
}
