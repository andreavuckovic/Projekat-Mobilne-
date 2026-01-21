import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
          ),
        );
      },
    );
  }
}
