library test.nv.storage;

import 'dart:async';
import 'package:unittest/unittest.dart';
import 'package:nv/src/storage.dart';

import 'package:nv/debug.dart';

void testStorage(Map<String, Storage> stores) {
  group('test storage', () {
    stores.forEach((String storeName, Storage store) {
      group(storeName, () {
        main(store);
      });
    });
  });

}

void main(Storage storage) {
  setUp(() {
    return storage.clear();
  });

  test('store pnp', () {
      return storage.addAll(PNP)
        .then((_) {
          return storage.getKeys();
        })
        .then((List<String> keys) {
          expect(keys, unorderedEquals(PNP.keys));
    });
  });

  test('add many and clear', () {
    return storage.addAll(_validValues)
    .then((_) {
      return _matchesValidValues(storage);
    })
    .then((_) {
      return storage.clear();
    })
    .then((_) {
      return Future.forEach(_validValues.keys, (key) {
        return storage.get(key)
            .then((value) {
              expect(value, null);
            });
      });
    });
  });

  test('addAll, getKeys', () {
    return storage.getKeys()
        .then((List<String> keys) {
          expect(keys, isEmpty);

          return storage.addAll(_validValues);
        })
        .then((_) {
          return _matchesValidValues(storage);
        });
  });

  group('store values', () {
    const key = 'test_key';

    for(var description in _validValues.keys) {
      var testValue = _validValues[description];

      test(description, () {

        return storage.get(key)
            .then((value) {
              expect(value, isNull);

              return storage.set(key, testValue);
            })
            .then((_) {
              return storage.get(key);
            })
            .then((dynamic value) {
              expect(value, testValue);

              return storage.remove(key);
            })
            .then((dynamic value) {
              return storage.get(key);
            })
            .then((value) {
              expect(value, isNull);
            });
      });
    }
  });
}

Future _matchesValidValues(Storage storage) {
  return storage.getKeys()
    .then((List<String> keys) {
      expect(keys, unorderedEquals(_validValues.keys));

      return Future.forEach(keys, (k) {
        return storage.get(k)
            .then((dynamic value) {
              expect(value, _validValues[k]);
            });
      });
    });
}

const _validValues = const {
  'null': null,
  'string': 'a string',
  'int': 42,
  'double': 3.1415,
  'array': const [1,2,3,4],
  'map': const {
    'int': 42,
    'array': const [1,2,3],
    'map': const { 'a':1, 'b':2}
  }
};
