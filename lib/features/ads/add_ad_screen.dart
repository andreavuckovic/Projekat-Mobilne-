import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'ad_model.dart';
import 'ads_provider.dart';

class AddAdScreen extends ConsumerStatefulWidget {
  const AddAdScreen({super.key});

  @override
  ConsumerState<AddAdScreen> createState() => _AddAdScreenState();
}

class _AddAdScreenState extends ConsumerState<AddAdScreen> {
  final _formKey = GlobalKey<FormState>();

  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final priceCtrl = TextEditingController();

  AdCategory cat = AdCategory.elektronika;

  @override
  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: titleCtrl,
            decoration: const InputDecoration(
              labelText: 'Naslov',
              border: OutlineInputBorder(),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Unesi naslov' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: descCtrl,
            decoration: const InputDecoration(
              labelText: 'Opis',
              border: OutlineInputBorder(),
            ),
            minLines: 2,
            maxLines: 5,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Unesi opis' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: priceCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Cena (EUR)',
              border: OutlineInputBorder(),
            ),
            validator: (v) {
              final p = double.tryParse((v ?? '').trim());
              if (p == null || p <= 0) return 'Unesi cenu > 0';
              return null;
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<AdCategory>(
            value: cat,
            decoration: const InputDecoration(
              labelText: 'Kategorija',
              border: OutlineInputBorder(),
            ),
            items: AdCategory.values
                .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                .toList(),
            onChanged: (v) => setState(() => cat = v ?? cat),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.check),
            label: const Text('Sačuvaj oglas'),
            onPressed: () {
              if (!_formKey.currentState!.validate()) return;

              final price = double.parse(priceCtrl.text.trim());

              ref.read(adsProvider.notifier).addAd(
                    title: titleCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    category: cat,
                    price: price,
                  );

              // vrati na Home
              context.go('/');
            },
          ),
        ],
      ),
    );
  }
}
