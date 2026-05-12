import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import '../../data/remote/firestore_service.dart';
import '../../data/models/member_model.dart';
import '../../data/models/division_model.dart';
class MemberFormScreen extends StatefulWidget {
  final MemberModel? member;

  const MemberFormScreen({super.key, this.member});

  @override
  State<MemberFormScreen> createState() => _MemberFormScreenState();
}

class _MemberFormScreenState extends State<MemberFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  late final TextEditingController _nameController;
  late final TextEditingController _nrpController;
  late final TextEditingController _positionController;

  String? _selectedDivision;
  String? _photoBase64;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  bool get _isEditing => widget.member != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.member?.name ?? '');
    _nrpController = TextEditingController(text: widget.member?.nrp ?? '');
    _positionController =
        TextEditingController(text: widget.member?.position ?? '');
    _selectedDivision = widget.member?.division;
    if (_selectedDivision != null && _selectedDivision!.isEmpty) {
      _selectedDivision = null;
    }
    _photoBase64 = widget.member?.photoUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nrpController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  Future<void> _showImageSourcePicker() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded),
                title: const Text('Ambil dari Kamera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.folder_rounded),
                title: const Text('Pilih dari File/Galeri'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source != null) {
      await _pickImage(source);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 70,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _photoBase64 = base64Encode(bytes);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDivision == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih divisi')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final member = MemberModel(
      name: _nameController.text.trim(),
      nrp: _nrpController.text.trim(),
      division: _selectedDivision!,
      position: _positionController.text.trim(),
      photoUrl: _photoBase64,
    );

    try {
      if (_isEditing) {
        await _firestoreService.updateMember(widget.member!.id!, member);
      } else {
        await _firestoreService.addMember(member);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing
                ? 'Anggota berhasil diperbarui'
                : 'Anggota berhasil ditambahkan'),
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
        title: Text(_isEditing ? 'Edit Anggota' : 'Tambah Anggota'),
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
                    child: GestureDetector(
                      onTap: _showImageSourcePicker,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          shape: BoxShape.circle,
                          image: _photoBase64 != null
                              ? DecorationImage(
                                  image: MemoryImage(base64Decode(_photoBase64!)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _photoBase64 == null
                            ? const Icon(Icons.camera_alt_rounded,
                                color: Color(0xFF1565C0), size: 32)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton.icon(
                      onPressed: _showImageSourcePicker,
                      icon: const Icon(Icons.add_a_photo_rounded),
                      label: const Text('Pilih Foto (Kamera / File)'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildField(
                    controller: _nameController,
                    label: 'Nama Lengkap',
                    hint: 'Masukkan nama lengkap',
                    icon: Icons.person_outline,
                    validator: (val) =>
                        val!.trim().isEmpty ? 'Nama wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    controller: _nrpController,
                    label: 'NRP',
                    hint: 'Masukkan NRP',
                    icon: Icons.badge_outlined,
                    validator: (val) =>
                        val!.trim().isEmpty ? 'NRP wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  StreamBuilder<List<DivisionModel>>(
                    stream: _firestoreService.getDivisions(),
                    builder: (context, snapshot) {
                      List<DropdownMenuItem<String>> items = [];
                      if (snapshot.hasData) {
                        items = snapshot.data!.map((div) {
                          return DropdownMenuItem(
                            value: div.name,
                            child: Text(div.name),
                          );
                        }).toList();
                      }
                      
                      // Check if _selectedDivision is not in items, set to null
                      if (_selectedDivision != null && items.isNotEmpty) {
                        bool found = items.any((item) => item.value == _selectedDivision);
                        if (!found && !_isEditing) {
                          _selectedDivision = null;
                        }
                      }

                      return DropdownButtonFormField<String>(
                        initialValue: _selectedDivision,
                        decoration: InputDecoration(
                          labelText: 'Divisi',
                          prefixIcon: Icon(Icons.account_tree_outlined, size: 20, color: Colors.grey[500]),
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
                        ),
                        items: items,
                        hint: const Text('Pilih Divisi'),
                        validator: (val) => val == null ? 'Divisi wajib dipilih' : null,
                        onChanged: (val) {
                          setState(() {
                            _selectedDivision = val;
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    controller: _positionController,
                    label: 'Jabatan',
                    hint: 'Masukkan jabatan',
                    icon: Icons.work_outline,
                    validator: (val) =>
                        val!.trim().isEmpty ? 'Jabatan wajib diisi' : null,
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
                              _isEditing ? 'Simpan Perubahan' : 'Tambah Anggota',
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
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: Colors.grey[500]),
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
