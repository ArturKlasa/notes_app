import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:notes_app/models/note.dart';
import 'package:path_provider/path_provider.dart';

//add "extends ChangeNotifier" to user Provider with it
class NoteDatabase extends ChangeNotifier {
  static late Isar isar;

  //initialize DB
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([NoteSchema], directory: dir.path);
  }

  //list of notes
  final List<Note> currentNotes = [];

  //CREATE
  Future<void> addNote(String textFromUser) async {
    //create a new note object
    final newNote = Note()..text = textFromUser;
    //save to db
    await isar.writeTxn(() => isar.notes.put(newNote));
  }

  //READ
  Future<void> fetchNotes() async {
    List<Note> fetchedNotes = await isar.notes.where().findAll();
    currentNotes.clear();
    currentNotes.addAll(fetchedNotes);
    notifyListeners(); //notifify listeners about the change (update and delete methods have fetchNotes() at the end, so they'll do that too)
  }

  //UPDATE
  Future<void> updateNotes(int id, String newText) async {
    //assign existing note to a variable
    final existingNote = await isar.notes.get(id);
    //if it exists then assing a new value to the existing note
    if (existingNote != null) {
      existingNote.text = newText;
      await isar
          .writeTxn(() => isar.notes.put(existingNote)); //this line updates it
      await fetchNotes(); //updates note
    }
  }

  //DELETE
  Future<void> deleteNote(int id) async {
    await isar.writeTxn(() => isar.notes.delete(id));
    await fetchNotes();
  }
}
