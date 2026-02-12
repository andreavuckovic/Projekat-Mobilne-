import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_provider.dart';
import 'ad_model.dart';
import 'ads_repo_provider.dart';

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
  final contactCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final imageUrlCtrl = TextEditingController();

  AdCategory cat = AdCategory.elektronika;

  bool saving = false;

  @override
  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    priceCtrl.dispose();
    contactCtrl.dispose();
    cityCtrl.dispose();
    imageUrlCtrl.dispose();
    super.dispose();
  }

  bool _looksLikeUrl(String s) {
    final v = s.trim();
    return v.startsWith('http://') || v.startsWith('https://');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = ref.read(authProvider);
    if (auth.user == null) return;

    setState(() => saving = true);

    final repo = ref.read(adsRepoProvider);

    try {
      final url = imageUrlCtrl.text.trim();
      final urls = url.isEmpty ? const <String>[] : <String>[url];

      final ad = Ad(
        id: '',
        title: titleCtrl.text.trim(),
        description: descCtrl.text.trim(),
        category: cat,
        price: double.parse(priceCtrl.text.trim()),
        ownerId: auth.user!.id,
        ownerName: auth.user!.displayName,
        contact: contactCtrl.text.trim(),
        city: cityCtrl.text.trim(),
        images: const [],
        imageUrls: urls,
      );

      await repo.add(ad);

      if (mounted) context.go('/');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Greška: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final previewUrl = imageUrlCtrl.text.trim();

    return Scaffold(
      appBar: AppBar(title: const Text('Novi oglas')),
      body: Form(
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
            TextFormField(
              controller: contactCtrl,
              decoration: const InputDecoration(
                labelText: 'Kontakt',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Unesi kontakt' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: cityCtrl,
              decoration: const InputDecoration(
                labelText: 'Grad',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Unesi grad' : null,
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
            const SizedBox(height: 12),
            TextFormField(
              controller: imageUrlCtrl,
              decoration: const InputDecoration(
                labelText: 'Image URL (opciono)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
              onChanged: (_) => setState(() {}),
              validator: (v) {
                final s = (v ?? '').trim();
                if (s.isEmpty) return null;
                if (!_looksLikeUrl(s)) return 'Unesi http/https link';
                return null;
              },
            ),
            const SizedBox(height: 12),
            if (previewUrl.isNotEmpty && _looksLikeUrl(previewUrl))
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    previewUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      alignment: Alignment.center,
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      child: const Text('Ne mogu da učitam sliku'),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: Text(saving ? 'Sačuvavam...' : 'Sačuvaj oglas'),
              onPressed: saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}
