import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'ad_model.dart';
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

  AdCategory cat = AdCategory.elektronika;

  bool saving = false;
  bool _inited = false;

  final _picker = ImagePicker();
  List<Uint8List> _images = [];

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
    final files = await _picker.pickMultiImage(imageQuality: 85);
    if (files.isEmpty) return;

    final bytesList = await Future.wait(files.map((f) => f.readAsBytes()));
    setState(() {
      _images.addAll(bytesList);
    });
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _save(Ad original) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => saving = true);

    try {
      await ref.read(adsActionsProvider.notifier).updateAd(
            original: original,
            title: titleCtrl.text.trim(),
            description: descCtrl.text.trim(),
            category: cat,
            price: double.parse(priceCtrl.text.trim()),
            contact: contactCtrl.text.trim(),
            city: cityCtrl.text.trim(),
            newImages: List<Uint8List>.from(_images),
          );

      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final adsAsync = ref.watch(adsStreamProvider);
    final imagesAsync = ref.watch(adImagesProvider(widget.adId));
    final theme = Theme.of(context);

    return adsAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
      data: (ads) {
        final ad = ads.where((a) => a.id == widget.adId).firstOrNull;
        if (ad == null) {
          return const Scaffold(
            body: Center(child: Text('Ad not found.')),
          );
        }

        if (!_inited) {
          titleCtrl.text = ad.title;
          descCtrl.text = ad.description;
          priceCtrl.text = ad.price.toStringAsFixed(0);
          contactCtrl.text = ad.contact;
          cityCtrl.text = ad.city;
          cat = ad.category;
          _inited = true;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Ad'),
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
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter a title' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descCtrl,
                  minLines: 2,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Enter a description'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Price (EUR)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final p = double.tryParse((v ?? '').trim());
                    if (p == null || p <= 0) return 'Enter a price greater than 0';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: contactCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Contact',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Enter contact information'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: cityCtrl,
                  decoration: const InputDecoration(
                    labelText: 'City',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter city' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<AdCategory>(
                  value: cat,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: AdCategory.values
                      .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                      .toList(),
                  onChanged: (v) => setState(() => cat = v ?? cat),
                ),
                const SizedBox(height: 12),
                Text(
                  'Current images',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                imagesAsync.when(
                  loading: () => Container(
                    height: 110,
                    alignment: Alignment.center,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const CircularProgressIndicator(),
                  ),
                  error: (e, _) => Text('Error: $e'),
                  data: (imgs) {
                    if (imgs.isEmpty) {
                      return Container(
                        height: 110,
                        alignment: Alignment.center,
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Text('No images.'),
                      );
                    }
                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final b in imgs)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.memory(
                              b,
                              width: 110,
                              height: 110,
                              fit: BoxFit.cover,
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(
                    _images.isEmpty ? 'Add new images' : 'Add more (${_images.length})',
                  ),
                  onPressed: saving ? null : _pickImages,
                ),
                const SizedBox(height: 12),
                if (_images.isNotEmpty)
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (int i = 0; i < _images.length; i++)
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.memory(
                                _images[i],
                                width: 110,
                                height: 110,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              right: 6,
                              top: 6,
                              child: InkWell(
                                onTap: saving ? null : () => _removeImage(i),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface.withOpacity(0.9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, size: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: Text(saving ? 'Saving...' : 'Save changes'),
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
