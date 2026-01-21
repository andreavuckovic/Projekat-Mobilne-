import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'ads_provider.dart';
import 'ad_model.dart';

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

  AdCategory cat = AdCategory.elektronika;
  bool _inited = false;

  final _picker = ImagePicker();
  final List<Uint8List> _images = [];

  @override
  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    priceCtrl.dispose();
    contactCtrl.dispose();
    cityCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final files = await _picker.pickMultiImage(imageQuality: 80);
    if (files.isEmpty) return;

    for (final f in files) {
      final bytes = await f.readAsBytes();
      _images.add(bytes);
    }
    setState(() {});
  }

  Future<void> _confirmDelete(String adId) async {
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
      if (mounted) context.go('/my-ads');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ads = ref.watch(adsProvider);
    final ad = ads.where((a) => a.id == widget.adId).firstOrNull;

    if (ad == null) {
      return const Scaffold(body: Center(child: Text('Oglas nije pronađen.')));
    }

    if (!_inited) {
      titleCtrl.text = ad.title;
      descCtrl.text = ad.description;
      priceCtrl.text = ad.price.toStringAsFixed(0);
      contactCtrl.text = ad.contact;
      cityCtrl.text = ad.city;
      cat = ad.category;
      _images
        ..clear()
        ..addAll(ad.images);
      _inited = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Izmeni oglas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(ad.id),
          ),
        ],
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
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Dodaj slike'),
                  ),
                ),
                const SizedBox(width: 12),
                Text('${_images.length} slika'),
              ],
            ),
            if (_images.isNotEmpty) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 92,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            _images[i],
                            width: 92, 
                            height: 92,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          right: 4,
                          top: 4,
                          child: InkWell(
                            onTap: () {
                              setState(() => _images.removeAt(i));
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Sačuvaj izmene'),
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;

                ref.read(adsProvider.notifier).updateAd(
                      id: ad.id,
                      title: titleCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      category: cat,
                      price: double.parse(priceCtrl.text.trim()),
                      contact: contactCtrl.text.trim(),
                      city: cityCtrl.text.trim(),
                      images: List<Uint8List>.from(_images),
                    );

                context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
