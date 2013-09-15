library test.nv.app_controller;

import 'dart:async';
import 'package:unittest/unittest.dart';

import 'package:nv/src/config.dart';
import 'package:nv/src/controllers.dart';
import 'package:nv/src/models.dart';
import 'package:nv/src/serialization.dart';
import 'package:nv/src/shared.dart';
import 'package:nv/src/storage.dart';
import 'package:nv/src/sync.dart';

const _testTitle1 = 'Test Title 1';

void main(Storage storageFactory()) {
  group('AppController', () {

    _testAppController('simple', storageFactory, _testSimple);

    _testAppController('initial search', storageFactory, _initialSearch);

    _testAppController('select item, edit, sort=stable', storageFactory,
        (AppController ac) {
      _expectFirstRun(ac);

      expect(ac.notes, hasLength(INITIAL_NOTES.length));

      var expectedSortedTitles = INITIAL_NOTES.keys.toList()
          ..sort();

      var controllerTitles = ac.notes
          .map((Selectable<Note> s) => s.value.title)
          .toList();

      expect(controllerTitles, orderedEquals(expectedSortedTitles));
    });

  });
}

Future _initialSearch(AppController ac) {
  expect(ac.notes.hasSelection, isFalse);

  expect(INITIAL_NOTES.keys, contains('About'));
  expect(INITIAL_NOTES.keys.where((k) => k.toLowerCase().startsWith('a')),
      hasLength(1), reason: 'should have only one item that begins w/ "A"');

  // TODO: start hacking on partial completion of item, etc
}

Future _testSimple(AppController controller) {
  _expectFirstRun(controller);

  final tc = new TextContent('first content!');

  controller.searchTerm = _testTitle1;

  return _whenUpdated(controller)
      .then((_) {

        expect(controller.notes.hasSelection, isFalse);

        var note = controller.openOrCreate();
        expect(note, isNotNull);

        var nc = note.content;
        expect(nc is TextContent, isTrue);
        expect(nc.value, isEmpty);

        controller.updateSelectedNoteContent(tc.value);

        var titleVariations = _permutateTitle(_testTitle1)
          ..add('Test');

        /*

        TODO: need to futz w/ search logic here
        for(var t in titleVariations) {
          model.searchTerm = t;
          var nc = model.openOrCreate();
          expect(nc.title, _testTitle1);
          expect(nc.content, tc);
        }*/

        return _whenUpdated(controller);
      });
}

List<String> _permutateTitle(String title) {
  expect(title, title);
  expect(title.toLowerCase(), isNot(title));
  expect(title.toUpperCase(), isNot(title));
  expect(title.toUpperCase(), isNot(title.toLowerCase()));

  return [title, title.toLowerCase(), title.toUpperCase()];
}

Future<AppController> _whenUpdated(AppController controller) {
  if(controller.isUpdated) {
    return new Future.value(controller);
  }

  return new Future(() => _whenUpdated(controller));
}

Future _expectFirstRun(AppController controller) {
  expect(controller.notes, hasLength(INITIAL_NOTES.length));

  for(Selectable<Note> note in controller.notes) {
    var match = INITIAL_NOTES[note.value.title];
    expect(match, isNotNull);
    expect(note.value.content is TextContent, isTrue);

    TextContent tc = note.value.content;
    expect(tc.value, match);
  }
}

Future<AppController> _getDebugController(Storage storage) {
  return MapSync.createAndLoad(storage, NOTE_CODEC)
    .then((MapSync<Note> ms) => new AppController(ms))
    .then(_whenUpdated);
}

void _testAppController(String name, Storage storageFactory(), testFunc(AppController ac)) {
  test(name, () {
    var storage = storageFactory();
    return _getDebugController(storage).then(testFunc);
  });
}

