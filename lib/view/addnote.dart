import 'package:flutter/material.dart';
import 'package:todolist/model/checkbox_model.dart';
import 'package:todolist/model/note_model.dart';
import 'package:todolist/db/db_helper.dart';

class AddNote extends StatefulWidget {
  @override
  State<AddNote> createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {
  List<CheckboxModel> _checkboxList = [];
  DbHelper db = DbHelper();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _deskripsiController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _saveToDatabase() async {
    if (_formKey.currentState!.validate()) {
      // Form is valid, proceed to save
      final newNote = TitleModel(
        title: _titleController.text,
        deskripsi: _deskripsiController.text,
      );
      final noteId = await db.insertTitle(newNote);

      for (var checkbox in _checkboxList) {
        checkbox.titleId = noteId; // Set the titleId for each checkbox
        await db.insertCheckbox(checkbox);
      }

      Navigator.pop(context, true); // Pop the screen and return true
    }
  }

  void _addCheckBox() {
    setState(() {
      _checkboxList.add(
        CheckboxModel(
          titleId: 0, // Temporary value, will be updated in _saveToDatabase
          isChecked: false,
          title: '',
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Catatan'),
        actions: [
          IconButton(
            onPressed: () {
              _saveToDatabase();
            },
            icon: Icon(Icons.check),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          // padding: EdgeInsets.only(left: 50.0, top: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 50, top: 25),
                child: TextFormField(
                  controller: _titleController,
                  style: TextStyle(fontSize: 35),
                  decoration: InputDecoration(
                    hintText: 'Judul',
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
                padding: const EdgeInsets.only(left: 50),
                child: TextFormField(
                  controller: _deskripsiController,
                  minLines: 3,
                  maxLines: 5,
                  style: TextStyle(fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Deskripsi',
                    border: InputBorder.none,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 35),
                child: IconButton(
                  onPressed: _addCheckBox,
                  icon: Icon(Icons.add),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _checkboxList.length,
                itemBuilder: (context, index) {
                  final checkboxItem = _checkboxList[index];
                  return ListTile(
                    leading: Checkbox(
                      value: checkboxItem.isChecked,
                      onChanged: (value) {
                        setState(() {
                          checkboxItem.isChecked = value ?? false;
                        });
                      },
                    ),
                    title: TextFormField(
                      initialValue: checkboxItem.title,
                      onChanged: (value) {
                        checkboxItem.title = value;
                      },
                      decoration: const InputDecoration(
                        hintText: 'Isi Todo',
                        border: InputBorder.none,
                      ),
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
