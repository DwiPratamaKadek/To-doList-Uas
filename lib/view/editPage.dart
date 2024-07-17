import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:todolist/db/db_helper.dart';
import 'package:todolist/model/checkbox_model.dart';
import 'package:todolist/model/note_model.dart';

class EditPage extends StatefulWidget {
  final TitleModel titleModel;
  final Function(TitleModel) onUpdate;

  EditPage({required this.titleModel, required this.onUpdate});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late TextEditingController _titleController;
  late TextEditingController _deskripsiController;
  DbHelper db = DbHelper();
  List<CheckboxModel> _checkboxList = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.titleModel.title ?? '');
    _deskripsiController =
        TextEditingController(text: widget.titleModel.deskripsi ?? "");
    //menambahkan fetch
    _fetchCheckboxes(widget.titleModel.id ?? 0);
  }

  @override
  void _dispose() {
    _titleController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _fetchCheckboxes(int titleId) async {
    final checkboxes = await db.getCheckboxes(widget.titleModel.id!);
    setState(() {
      _checkboxList = checkboxes;
    });
  }

  Future<void> _updateNote() async {
    final updatedNote = TitleModel(
      id: widget.titleModel.id,
      title: _titleController.text,
      deskripsi: _deskripsiController.text,
    );
    await db.updateTitle(updatedNote);

    for (var checkbox in _checkboxList) {
      await db.updateCheckbox(checkbox);
    }

    // Memanggil callback onUpdate untuk memperbarui data di halaman Home
    widget.onUpdate(updatedNote);

    Navigator.pop(context);
  }

  Future<void> _addCheckBox() async {
    final newCheckbox = CheckboxModel(
        titleId: widget.titleModel.id!, isChecked: false, title: '');
    await db.insertCheckbox(newCheckbox);
    setState(() {
      _checkboxList.add(newCheckbox);
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                // Menambahkan fungsi tambah ke database dan menampilkan ke home
                _updateNote();
              },
              icon: const Icon(Icons.check))
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 50, right: 30),
                child: TextFormField(
                  controller: _titleController,
                  minLines: 1,
                  maxLines: 1,
                  style: const TextStyle(fontSize: 35),
                  decoration: const InputDecoration(
                    hintText: 'Judul List',
                    border: InputBorder.none,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Judul tidak boleh kosong';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 50, right: 20),
                child: TextFormField(
                  controller: _deskripsiController,
                  minLines: 1,
                  maxLines: 50,
                  style: const TextStyle(fontSize: 15),
                  decoration: const InputDecoration(
                    hintText: 'Deskripsi',
                    border: InputBorder.none,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 35),
                child: IconButton(
                    onPressed: () {
                      _addCheckBox();
                    },
                    icon: Icon(Icons.edit)),
              ),
              const SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _checkboxList.length,
                itemBuilder: (context, index) {
                  final item = _checkboxList[index];
                  return Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Row(
                      children: [
                        Checkbox(
                          value: item.isChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              item.isChecked = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  item.title = value;
                                });
                              },
                              controller:
                                  TextEditingController(text: item.title),
                              decoration: InputDecoration(
                                hintText: 'isi Todo',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
