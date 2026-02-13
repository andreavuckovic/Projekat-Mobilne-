import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../auth/auth_provider.dart';
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
  final contactCtrl = TextEditingController();
  final cityCtrl = TextEditingController();

  AdCategory cat = AdCategory.elektronika;
  bool saving = false;

  final _picker = ImagePicker();
  final List<Uint8List> _pickedImages = [];

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
      _pickedImages.addAll(bytesList);
    });
  }

  void _removeImage(int index) {
    setState(() {
      _pickedImages.removeAt(index);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = ref.read(authProvider);
    if (auth.user == null) return;

    setState(() => saving = true);

    try {
      await ref.read(adsActionsProvider.notifier).addAd(
            title: titleCtrl.text.trim(),
            description: descCtrl.text.trim(),
            category: cat,
            price: double.parse(priceCtrl.text.trim()),
            contact: contactCtrl.text.trim(),
            city: cityCtrl.text.trim(),
            images: List<Uint8List>.from(_pickedImages),
          );

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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('New ad')),
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
                  (v == null || v.trim().isEmpty) ? 'Title' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: descCtrl,
              decoration: const InputDecoration(
                labelText: 'Description', 
                border: OutlineInputBorder(),
              ),
              minLines: 2, 
              maxLines: 5,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Description' : null,
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
                if (p == null || p <= 0) return 'Price > 0';
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
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Contact' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: cityCtrl,
              decoration: const InputDecoration( 
                labelText: 'City',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'City' : null,
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
            OutlinedButton.icon(
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(_pickedImages.isEmpty
                  ? 'Add photos'
                  : 'Add more photos (${_pickedImages.length})'),
              onPressed: saving ? null : _pickImages,
            ),
            const SizedBox(height: 12),
            if (_pickedImages.isNotEmpty)
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (int i = 0; i < _pickedImages.length; i++)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.memory(
                            _pickedImages[i],
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
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: Text(saving ? 'Saving...' : 'Save ad'),  
              onPressed: saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}
 