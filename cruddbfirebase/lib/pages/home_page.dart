import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cruddbfirebase/services/firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final titleTextController = TextEditingController();
  final contentTextController = TextEditingController();
  final labelTextController = TextEditingController();
  DateTime? selectedDate;

  final FirestoreService firestoreService = FirestoreService();

  @override
  void dispose() {
    titleTextController.dispose();
    contentTextController.dispose();
    labelTextController.dispose();
    super.dispose();
  }

  void openNoteBox({
    String? docId,
    String? existingTitle,
    String? existingNote,
    String? existingLabel,
    DateTime? existingTgl,
  }) {
    if (docId != null) {
      titleTextController.text = existingTitle ?? '';
      contentTextController.text = existingNote ?? '';
      labelTextController.text = existingLabel ?? '';
      selectedDate = existingTgl;
    } else {
      titleTextController.clear();
      contentTextController.clear();
      labelTextController.clear();
      selectedDate = null;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(docId == null ? 'Create new Note' : 'Edit Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleTextController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: contentTextController,
                decoration: const InputDecoration(labelText: 'Content'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: labelTextController,
                decoration: const InputDecoration(labelText: 'Label'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedDate == null
                          ? 'Tanggal belum dipilih'
                          : 'Tgl: ${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}',
                    ),
                  ),
                  TextButton(
                    onPressed: pickDate,
                    child: const Text('Pilih Tgl'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            MaterialButton(
              onPressed: () async {
                if (selectedDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tanggal wajib diisi')),
                  );
                  return;
                }

                try {
                  if (docId == null) {
                    await firestoreService.addNote(
                      titleTextController.text,
                      contentTextController.text,
                      selectedDate!,
                      labelTextController.text,
                    );
                  } else {
                    await firestoreService.updateNote(
                      docId,
                      titleTextController.text,
                      contentTextController.text,
                      selectedDate!,
                      labelTextController.text,
                    );
                  }

                  titleTextController.clear();
                  contentTextController.clear();
                  labelTextController.clear();
                  selectedDate = null;
                  if (!context.mounted) return;
                  Navigator.pop(context);
                } on FirebaseException catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.message ?? 'Gagal menyimpan note')),
                  );
                } catch (_) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gagal menyimpan note')),
                  );
                }
              },
              child: Text(docId == null ? 'Create' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notes")),
      floatingActionButton: FloatingActionButton(
        onPressed: openNoteBox,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNotes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List notesList = snapshot.data!.docs;

            return GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.95,
              ),
              itemCount: notesList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = notesList[index];
                String docId = document.id;

                Map<String, dynamic> data = document.data() as Map<String, dynamic>;

                final String noteTitle = (data['title'] ?? '') as String;
                final String noteContent = (data['content'] ?? '') as String;
                final String noteLabel = (data['label'] ?? '-') as String;

                final Timestamp? ts = data['tgl'] as Timestamp?;
                final DateTime? noteTgl = ts?.toDate();
                final String tglText = noteTgl == null
                    ? '-'
                    : '${noteTgl.year}-${noteTgl.month.toString().padLeft(2, '0')}-${noteTgl.day.toString().padLeft(2, '0')}';

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          noteTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Text(
                            noteContent,
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                openNoteBox(
                                  docId: docId,
                                  existingTitle: noteTitle,
                                  existingNote: noteContent,
                                  existingLabel: noteLabel,
                                  existingTgl: noteTgl,
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                firestoreService.deleteNote(docId);
                              },
                            ),
                          ],
                        ),
                        Text(
                          noteLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tglText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return const Text("No data");
          }
        },
      ),
    );
  }
}