import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:todolist/db/db_helper.dart';
import 'package:todolist/model/checkbox_model.dart';
import 'package:todolist/model/note_model.dart';
import 'package:todolist/view/addnote.dart';
import 'package:todolist/view/Drawer.dart';
import 'package:todolist/view/editPage.dart';
import 'package:todolist/view/read.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<TitleModel> _noteList = [];
  Map<int, List<CheckboxModel>> _checkboxMap = {};
  List<String> _listColor = ['DADDB1', 'B3A492', 'BFB29E', 'D6C7AE'];
  DbHelper db = DbHelper();

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  Color hextoColor(String code) {
    return Color(int.parse(code.replaceFirst('#', ''), radix: 16) + 0xFF000000);
  }

  Color randomColor() {
    final randomHexColor = _listColor[Random().nextInt(_listColor.length)];
    return hextoColor(randomHexColor);
  }

  Future<void> _fetchNotes() async {
    final note = await db.getTitles();
    setState(() {
      _noteList = note;
    });
  }

  Future<void> _fetchCheckboxes(int titleId) async {
    final checkboxes = await db.getCheckboxes(titleId);
    setState(() {
      _checkboxMap[titleId] = checkboxes;
    });
  }

  void _updateNoteList(TitleModel updatedNote) {
    setState(() {
      // Cari indeks note yang diupdate dan update di dalam _noteList
      int index = _noteList.indexWhere((note) => note.id == updatedNote.id);
      if (index != -1) {
        _noteList[index] = updatedNote;
      }
    });
  }

  void _confirmDelete(TitleModel note) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Konfirmasi"),
          content: Text("Apakah Anda yakin ingin menghapus catatan ini?"),
          actions: <Widget>[
            TextButton(
              child: Text("Batal"),
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
            ),
            TextButton(
              child: Text("Hapus"),
              onPressed: () async {
                await db.deleteTitle(
                    note.id!); // Panggil fungsi delete dari DbHelper
                await db
                    .deleteCheckbox(note.id!); // Hapus juga checkbox terkait
                _fetchNotes(); // Ambil kembali catatan setelah dihapus
                Navigator.of(context).pop(); // Tutup dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: true,
            title: Padding(
              padding: const EdgeInsets.only(left: 20, top: 10),
              child: Image.asset(
                'images/MY LIST.png',
                scale: 14,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 20, top: 10),
                child: IconButton(
                  onPressed: () => _scaffoldKey.currentState!.openEndDrawer(),
                  icon: Icon(Icons.menu),
                ),
              ),
            ],
          ),
          SliverGrid(
            delegate: SliverChildBuilderDelegate((context, index) {
              final note = _noteList[index];
              final checkboxes = _checkboxMap[note.id] ?? [];
              final color = randomColor();
              return InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditPage(titleModel: note, onUpdate: _updateNoteList),
                  ),
                ).then((result) {
                  if (result != null) {
                    _fetchNotes();
                  }
                }),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: color,
                      border: Border.all(
                        color: Colors.black,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            margin: EdgeInsets.only(top: 10),
                            alignment: Alignment.center,
                            width: 70,
                            height: 2,
                            color: Colors.black,
                          ),
                        ),
                        Center(
                          child: Container(
                            margin: EdgeInsets.only(top: 5),
                            alignment: Alignment.center,
                            width: 50,
                            height: 2,
                            color: Colors.black,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 15, top: 50),
                          child: Text(
                            note.title ?? '',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Text(
                            note.deskripsi ?? '',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: IconButton(
                                onPressed: () => _confirmDelete(note),
                                icon: Icon(
                                  Icons.delete,
                                  size: 25,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 10, top: 10),
                              child: IconButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ReadPage(titleModel: note),
                                      ));
                                },
                                icon: Icon(Icons.remove_red_eye),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }, childCount: _noteList.length),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Pindah ke halaman AddNote dan tunggu hasilnya
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddNote(),
            ),
          );

          // Jika hasilnya tidak null, fetch notes lagi
          if (result != null) {
            _fetchNotes();
          }
        },
        child: Icon(Icons.add),
        tooltip: 'Tamabah Todo List',
      ),
      endDrawer: Drawer1(),
    );
  }
}
