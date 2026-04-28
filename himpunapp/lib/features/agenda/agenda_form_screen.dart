import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/remote/firestore_service.dart';
import '../../data/models/agenda_model.dart';
import '../../core/services/notification_service.dart';

class AgendaFormScreen extends StatefulWidget {
  final AgendaModel? agenda;

  const AgendaFormScreen({super.key, this.agenda});

  @override
  State<AgendaFormScreen> createState() => _AgendaFormScreenState();
}

class _AgendaFormScreenState extends State<AgendaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  late final TextEditingController _timeController;

  late DateTime _selectedDate;
  String _selectedStatus = 'upcoming';
  String? _photoBase64;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  bool get _isEditing => widget.agenda != null;

  final List<Map<String, String>> _statusOptions = [
    {'value': 'upcoming', 'label': 'Akan Datang'},
    {'value': 'ongoing', 'label': 'Berlangsung'},
    {'value': 'completed', 'label': 'Selesai'},
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.agenda?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.agenda?.description ?? '');
    _locationController =
        TextEditingController(text: widget.agenda?.location ?? '');
    _timeController = TextEditingController(text: widget.agenda?.time ?? '');
    _selectedDate = widget.agenda?.date ?? DateTime.now();
    _selectedStatus = widget.agenda?.status ?? 'upcoming';
    _photoBase64 = widget.agenda?.photoUrl;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _timeController.text =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
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
        maxWidth: 800,
        maxHeight: 800,
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

    setState(() => _isLoading = true);

    final agenda = AgendaModel(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      location: _locationController.text.trim(),
      date: _selectedDate,
      time: _timeController.text.trim(),
      status: _selectedStatus,
      photoUrl: _photoBase64,
    );

    try {
      if (_isEditing) {
        await _firestoreService.updateAgenda(widget.agenda!.id!, agenda);
      } else {
        await _firestoreService.addAgenda(agenda);
      }

      await NotificationService().scheduleAgendaReminder(agenda);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing
                ? 'Agenda berhasil diperbarui'
                : 'Agenda berhasil ditambahkan'),
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
    final dateFormat = DateFormat('dd MMMM yyyy');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Agenda' : 'Tambah Agenda'),
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
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.event_rounded,
                          color: Color(0xFFFF9800), size: 32),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: GestureDetector(
                      onTap: _showImageSourcePicker,
                      child: Container(
                        width: 150,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(12),
                          image: _photoBase64 != null
                              ? DecorationImage(
                                  image: MemoryImage(base64Decode(_photoBase64!)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _photoBase64 == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.camera_alt_rounded,
                                      color: Color(0xFF1565C0), size: 32),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Foto Bukti Lokasi\n(Kamera / File)',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: const Color(0xFF1565C0).withValues(alpha: 0.8),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildField(
                    controller: _titleController,
                    label: 'Judul Agenda',
                    hint: 'Masukkan judul agenda',
                    icon: Icons.title_rounded,
                    validator: (val) =>
                        val!.trim().isEmpty ? 'Judul wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    controller: _descriptionController,
                    label: 'Deskripsi',
                    hint: 'Masukkan deskripsi agenda',
                    icon: Icons.description_outlined,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  _buildField(
                    controller: _locationController,
                    label: 'Lokasi',
                    hint: 'Masukkan lokasi acara',
                    icon: Icons.location_on_outlined,
                    validator: (val) =>
                        val!.trim().isEmpty ? 'Lokasi wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),

                  // Date picker
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Tanggal',
                        prefixIcon: Icon(Icons.calendar_today_rounded,
                            size: 20, color: Colors.grey[500]),
                        filled: true,
                        fillColor: const Color(0xFFF5F7FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.grey[200]!, width: 1),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                      child: Text(dateFormat.format(_selectedDate)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Time picker
                  InkWell(
                    onTap: _pickTime,
                    borderRadius: BorderRadius.circular(12),
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _timeController,
                        decoration: InputDecoration(
                          labelText: 'Waktu',
                          hintText: 'Pilih waktu',
                          prefixIcon: Icon(Icons.access_time_rounded,
                              size: 20, color: Colors.grey[500]),
                          filled: true,
                          fillColor: const Color(0xFFF5F7FA),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: Colors.grey[200]!, width: 1),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                        validator: (val) =>
                            val!.trim().isEmpty ? 'Waktu wajib diisi' : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Status dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      prefixIcon: Icon(Icons.flag_outlined,
                          size: 20, color: Colors.grey[500]),
                      filled: true,
                      fillColor: const Color(0xFFF5F7FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.grey[200]!, width: 1),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                    items: _statusOptions
                        .map((opt) => DropdownMenuItem<String>(
                              value: opt['value'],
                              child: Text(opt['label']!),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedStatus = val);
                    },
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
                              _isEditing
                                  ? 'Simpan Perubahan'
                                  : 'Tambah Agenda',
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
