import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:todolist/db/db_helper.dart';
import 'package:todolist/model/checkbox_model.dart';
import 'package:todolist/model/note_model.dart';

class ReadPage extends StatefulWidget {
  final TitleModel titleModel;

  ReadPage({required this.titleModel});

  @override
  State<ReadPage> createState() => _ReadPageState();
}

class _ReadPageState extends State<ReadPage> {
  final _formkey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _deskripsiController;
  List<CheckboxModel> _checkboxs = [];
  bool _isCheck = true;
  DbHelper db = DbHelper();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.titleModel.title);
    _deskripsiController =
        TextEditingController(text: widget.titleModel.deskripsi);
    _loadNote();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _loadNote() async {
    final checkboxs = await db.getCheckboxes(widget.titleModel.id!);
    setState(() {
      _checkboxs = checkboxs;
      _isCheck = false;
    });
  }

  void _addCheckBox() {
    setState(() {
      _checkboxs
          .add(CheckboxModel(titleId: widget.titleModel.id!, isChecked: false));
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // actions: [
          //   IconButton(
          //       onPressed: () {
          //         // Menambahkan fungsi tambah ke database dan menampilkan ke home
          //         _loadNote();
          //       },
          //       icon: const Icon(Icons.check))
          // ],
          ),
      body: Form(
        key: _formkey,
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
                  readOnly: true,
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
                  readOnly: true,
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.only(left: 35),
              //   child: IconButton(
              //       onPressed: () {
              //         _addCheckBox();
              //       },
              //       icon: Icon(Icons.add)),
              // ),
              const SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _checkboxs.length,
                itemBuilder: (context, index) {
                  final item = _checkboxs[index];
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
                              readOnly: true,
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
