import 'package:flutter/material.dart';
import 'package:todolist/view/addnote.dart';

import 'package:todolist/view/home.dart';

class Drawer1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.6,
      child: ListView(
        children: [
          DrawerHeader(
            child: Image.asset('images/MY LIST.png'),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Home())),
                icon: Icon(Icons.list_alt),
              ),
              Text('List')
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddNote())),
                icon: Icon(Icons.note_add),
              ),
              Text('Tambah Todo List')
            ],
          )
        ],
      ),
    );
  }
}
