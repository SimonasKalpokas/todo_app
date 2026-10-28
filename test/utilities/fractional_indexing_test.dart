import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/utilities/fractional_indexing.dart';

void main() {
  group("indexBetween", () {
    test("both null returns middle value", () {
      expect(indexBetween(null, null), "n");
    });
    test("trailing 'a' in left or right", () {
      expect(() => indexBetween("a", null), throwsArgumentError);
      expect(() => indexBetween("aaa", null), throwsArgumentError);
      expect(() => indexBetween("a", "mn"), throwsArgumentError);
      expect(() => indexBetween("aa", "mn"), throwsArgumentError);

      expect(() => indexBetween(null, "a"), throwsArgumentError);
      expect(() => indexBetween(null, "aaaaa"), throwsArgumentError);
      expect(() => indexBetween("mn", "a"), throwsArgumentError);
      expect(() => indexBetween("mn", "aaaa"), throwsArgumentError);

      expect(() => indexBetween("a", "a"), throwsArgumentError);
    });
    test("empty left or right", () {
      expect(() => indexBetween("", null), throwsArgumentError);
      expect(() => indexBetween("", "mn"), throwsArgumentError);

      expect(() => indexBetween(null, ""), throwsArgumentError);
      expect(() => indexBetween("mn", ""), throwsArgumentError);

      expect(() => indexBetween("", ""), throwsArgumentError);
    });
    test("left is greater or equal to right", () {
      expect(() => indexBetween("mn", "d"), throwsArgumentError);
      expect(() => indexBetween("uad", "mn"), throwsArgumentError);
      expect(() => indexBetween("uad", "uac"), throwsArgumentError);

      expect(() => indexBetween("d", "d"), throwsArgumentError);
      expect(() => indexBetween("uad", "uad"), throwsArgumentError);
    });
    test("invalid characters", () {
      expect(() => indexBetween("B", null), throwsArgumentError);
      expect(() => indexBetween("a1b", null), throwsArgumentError);
    });
    test("one of left and right is null", () {
      expect(indexBetween(null, "c"), "b");
      expect(indexBetween(null, "calskdj"), "b");
      expect(indexBetween(null, "zasjldkj"), "m");
      expect(indexBetween(null, "aac"), "aab");

      expect(indexBetween("x", null), "y");
      expect(indexBetween("y", null), "z");
      expect(indexBetween("yz", null), "z");
      expect(indexBetween("yzx", null), "z");
      expect(indexBetween("z", null), "zn");
      expect(indexBetween("zzz", null), "zzzn");
      expect(indexBetween("zzx", null), "zzy");
    });
    test("left is prefix of right", () {
      expect(indexBetween("mn", "mnt"), "mnj");
      expect(indexBetween("mn", "mnttt"), "mnj");
      expect(indexBetween("mn", "mnat"), "mnaj");
      expect(indexBetween("mn", "mnaaat"), "mnaaaj");
    });
    test("different first char", () {
      expect(indexBetween("b", "d"), "c");
      expect(indexBetween("b", "e"), "c");
      expect(indexBetween("b", "f"), "d");

      expect(indexBetween("b", "c"), "bn");
      expect(indexBetween("bx", "c"), "by");
      expect(indexBetween("by", "c"), "bz");
      expect(indexBetween("bz", "c"), "bzn");
    });
    test("null left with right starting with 'a'", () {
      expect(indexBetween(null, "b"), "an");
      expect(indexBetween(null, "ab"), "aan");
      expect(indexBetween(null, "an"), "ag");
      expect(indexBetween(null, "aab"), "aaan");
    });
    test("left's first char is one below right's, left has more chars", () {
      expect(indexBetween("an", "b"), "at");
      expect(indexBetween("az", "b"), "azn");
      expect(indexBetween("mab", "mb"), "man");
    });
    test("right extends left with leading 'a's", () {
      expect(indexBetween("m", "mab"), "maan");
      expect(indexBetween("b", "bb"), "ban");
    });
    test("shared prefix, adjacent chars after it", () {
      expect(indexBetween("mn", "mo"), "mnn");
      expect(indexBetween("mnz", "mo"), "mnzn");
    });
    test("result is strictly between and well-formed", () {
      final cases = [
        [null, null],
        [null, "b"],
        ["y", null],
        ["b", "c"],
        ["mn", "mnt"],
        ["az", "b"],
        ["zz", null],
        [null, "aab"],
      ];
      for (final c in cases) {
        final result = indexBetween(c[0], c[1]);
        if (c[0] != null) expect(c[0]!.compareTo(result) < 0, isTrue);
        if (c[1] != null) expect(result.compareTo(c[1]!) < 0, isTrue);
        expect(result, matches(RegExp(r'^[a-z]*[b-z]$')),
            reason: "no trailing 'a', only a-z");
      }
    });
    test("random insertions keep the list sorted and unique", () {
      final rng = Random(42);
      final list = <String>[];
      for (var i = 0; i < 1000; i++) {
        final pos = rng.nextInt(list.length + 1);
        final left = pos == 0 ? null : list[pos - 1];
        final right = pos == list.length ? null : list[pos];
        list.insert(pos, indexBetween(left, right));
      }
      for (var i = 0; i < list.length - 1; i++) {
        expect(list[i].compareTo(list[i + 1]) < 0, isTrue);
      }
      expect(list.toSet().length, list.length);
    });
    test("repeated insertion at the same spot never produces trailing 'a'", () {
      // always inserting at the front
      var right = "n";
      for (var i = 0; i < 200; i++) {
        final s = indexBetween(null, right);
        expect(s.compareTo(right) < 0, isTrue);
        expect(s.endsWith("a"), isFalse);
        right = s;
      }
      // always inserting at the back
      var left = "n";
      for (var i = 0; i < 200; i++) {
        final s = indexBetween(left, null);
        expect(s.compareTo(left) > 0, isTrue);
        left = s;
      }
    });
  });
  group("nIndexesBetween", () {
    test("zero returns empty list", () {
      expect(nIndexesBetween(0, null, null), isEmpty);
      expect(nIndexesBetween(0, "b", "c"), isEmpty);
    });

    test("negative n throws", () {
      expect(() => nIndexesBetween(-1, null, null), throwsArgumentError);
    });

    test("n = 1 matches indexBetween", () {
      expect(nIndexesBetween(1, null, null), [indexBetween(null, null)]);
      expect(nIndexesBetween(1, "b", "d"), [indexBetween("b", "d")]);
    });

    test("known small results", () {
      expect(nIndexesBetween(2, null, null), ["n", "t"]);
      expect(nIndexesBetween(3, null, null), ["g", "n", "t"]);
      expect(nIndexesBetween(4, null, null), ["g", "n", "t", "w"]);
    });

    test("invalid bounds throw", () {
      expect(() => nIndexesBetween(3, "d", "b"), throwsArgumentError);
      expect(() => nIndexesBetween(3, "a", null), throwsArgumentError);
    });

    group("invariants", () {
      final bounds = <List<String?>>[
        [null, null],
        [null, "b"],
        [null, "aab"],
        ["y", null],
        ["zz", null],
        ["b", "c"], // tight: no room at the first character
        ["mn", "mnt"], // left is a prefix of right
        ["az", "b"],
        ["b", "bb"],
      ];

      for (final b in bounds) {
        for (final n in [1, 2, 3, 4, 5, 7, 8, 16, 100, 1000]) {
          test("n=$n between ${b[0]} and ${b[1]}", () {
            final result = nIndexesBetween(n, b[0], b[1]);

            expect(result.length, n);

            // strictly increasing, therefore also unique
            for (var i = 0; i < result.length - 1; i++) {
              expect(result[i].compareTo(result[i + 1]) < 0, isTrue,
                  reason: "${result[i]} !< ${result[i + 1]}");
            }

            // strictly inside the bounds
            if (b[0] != null) {
              expect(b[0]!.compareTo(result.first) < 0, isTrue);
            }
            if (b[1] != null) {
              expect(result.last.compareTo(b[1]!) < 0, isTrue);
            }

            // well-formed: only a-z, no trailing 'a'
            for (final s in result) {
              expect(s, matches(RegExp(r'^[a-z]*[b-z]$')));
            }
          });
        }
      }
    });

    test("key length grows logarithmically", () {
      final result = nIndexesBetween(1000, null, null);
      final maxLen = result.map((s) => s.length).reduce(max);
      // each recursion level adds at most one character; depth is ~log2(n)
      expect(maxLen, lessThanOrEqualTo((log(1001) / ln2).ceil() + 2));
    });

    test("results can be used as neighbors for further inserts", () {
      final list = nIndexesBetween(50, null, null);
      // insert between every adjacent pair, then check the order still holds
      final merged = <String>[];
      for (var i = 0; i < list.length - 1; i++) {
        merged.add(list[i]);
        merged.add(indexBetween(list[i], list[i + 1]));
      }
      merged.add(list.last);
      for (var i = 0; i < merged.length - 1; i++) {
        expect(merged[i].compareTo(merged[i + 1]) < 0, isTrue);
      }
    });
  });
}
