import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'ad_model.dart';
import 'ads_repo_provider.dart';
import 'ads_provider.dart';

class EditAdScreen extends ConsumerStatefulWidget {
  final String adId;
  const EditAdScreen({super.key, required this.adId});

  @override
  ConsumerState<EditAdScreen> createState() => _EditAdScreenState();
}

class _EditAdScreenState extends ConsumerState<EditAdScreen> {
  final _formKey = GlobalKey<FormState>();

  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final contactCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final imageUrlCtrl = TextEditingController();

  AdCategory cat = AdCategory.elektronika;
  bool saving = false;
  bool _inited = false;

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

  Future<void> _save(Ad original) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => saving = true);

    final repo = ref.read(adsRepoProvider);

    try {
      final url = imageUrlCtrl.text.trim();
      final urls = url.isEmpty ? const <String>[] : <String>[url];

      final updated = original.copyWith(
        title: titleCtrl.text.trim(),
        description: descCtrl.text.trim(),
        category: cat,
        price: double.parse(priceCtrl.text.trim()),
        contact: contactCtrl.text.trim(),
        city: cityCtrl.text.trim(),
        imageUrls: urls,
        images: const [],
      );

      await repo.update(updated);

      if (mounted) context.pop();
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
    final adsAsync = ref.watch(adsStreamProvider);

    return adsAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text('Greška: $e'))),
      data: (ads) {
        final ad = ads.where((a) => a.id == widget.adId).firstOrNull;
        if (ad == null) {
          return const Scaffold(
            body: Center(child: Text('Oglas nije pronađen.')),
          );
        }

        if (!_inited) {
          titleCtrl.text = ad.title;
          descCtrl.text = ad.description;
          priceCtrl.text = ad.price.toStringAsFixed(0);
          contactCtrl.text = ad.contact;
          cityCtrl.text = ad.city;
          cat = ad.category;
          imageUrlCtrl.text = ad.imageUrls.isNotEmpty ? ad.imageUrls.first : '';
          _inited = true;
        }

        final previewUrl = imageUrlCtrl.text.trim();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Izmeni oglas'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
          ),
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
                  minLines: 2,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Opis',
                    border: OutlineInputBorder(),
                  ),
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
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: Text(saving ? 'Sačuvavam...' : 'Sačuvaj izmene'),
                  onPressed: saving ? null : () => _save(ad),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
