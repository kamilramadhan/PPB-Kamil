import 'package:flutter/material.dart';
import '../../data/remote/firestore_service.dart';
import '../../data/models/division_model.dart';

class DivisionFormScreen extends StatefulWidget {
  final DivisionModel? division;

  const DivisionFormScreen({super.key, this.division});

  @override
  State<DivisionFormScreen> createState() => _DivisionFormScreenState();
}

class _DivisionFormScreenState extends State<DivisionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _headController;

  bool _isLoading = false;
  bool get _isEditing => widget.division != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.division?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.division?.description ?? '');
    _headController = TextEditingController(text: widget.division?.head ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _headController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final division = DivisionModel(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      head: _headController.text.trim(),
    );

    try {
      if (_isEditing) {
        await _firestoreService.updateDivision(widget.division!.id!, division);
      } else {
        await _firestoreService.addDivision(division);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing
                ? 'Divisi berhasil diperbarui'
                : 'Divisi berhasil ditambahkan'),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Divisi' : 'Tambah Divisi'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.account_tree_rounded,
                          color: Color(0xFF4CAF50), size: 32),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildField(
                    controller: _nameController,
                    label: 'Nama Divisi',
                    hint: 'Masukkan nama divisi',
                    icon: Icons.label_outline,
                    validator: (val) =>
                        val!.trim().isEmpty ? 'Nama divisi wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    controller: _headController,
                    label: 'Ketua Divisi',
                    hint: 'Masukkan nama ketua divisi',
                    icon: Icons.person_outline,
                    validator: (val) =>
                        val!.trim().isEmpty ? 'Ketua divisi wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    controller: _descriptionController,
                    label: 'Deskripsi',
                    hint: 'Masukkan deskripsi divisi',
                    icon: Icons.description_outlined,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                              ),
                            )
                          : Text(
                              _isEditing ? 'Simpan Perubahan' : 'Tambah Divisi',
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon:
            maxLines > 1 ? null : Icon(icon, size: 20, color: Colors.grey[500]),
        filled: true,
        fillColor: const Color(0xFFF5F7FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1565C0), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red[300]!, width: 1),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
