use context essentials2021
include shared-gdrive("map-reduce-definitions.arr", "10VnNW4MbHmHsSh05fj365dbzoVItGQbr")

include my-gdrive("map-reduce-common.arr")
import map-reduce, anagram-map, anagram-reduce, recommend, popular-pairs
  from my-gdrive("map-reduce-code.arr")
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# Write your examples and tests in here. These should not be tests of implementation-specific details (e.g., helper functions).

check "map-reduce works on an empty list":
  map-reduce(empty, wc-map, wc-reduce) is empty
end

check "map-reduce works on one file with one word":
  map-reduce([list: one-word], wc-map, wc-reduce) is [list: tv("red", 1)]
end

check "map-reduce works on one file":
  lst-same-els(map-reduce([list: wc-file1], wc-map, wc-reduce), 
    [list: tv("fish", 2), tv("red", 1), tv("blue", 1)], lam(x, a): x == a end) 
    is true
end

check "map-reduce works on multiple files":
  lst-same-els(map-reduce([list: wc-file1, wc-file2], wc-map, wc-reduce),
    [list: tv("fish", 3), tv("blue", 2), tv("river", 1), tv("red", 1),
      tv("the", 1), tv("into", 1)], lam(x, a): x == a end) is true
  lst-same-els(map-reduce([list: wc-file2, wc-file3], wc-map, wc-reduce),
    [list: tv("fish", 2), tv("river", 2), tv("blue", 2), tv("red", 1),
      tv("into", 1), tv("the", 1)], lam(x, a): x == a end) is true
  lst-same-els(map-reduce([list: wc-file1, wc-file2, wc-file3], wc-map, wc-reduce),
    [list: tv("fish", 4), tv("river", 2), tv("blue", 3), tv("red", 2),
      tv("into", 1), tv("the", 1)], lam(x, a): x == a end) is true
end

check "anagram-map and anagram-reduce work on an empty list":
  map-reduce(empty, anagram-map, anagram-reduce) is empty
end

check "anagram-map and anagram-reduce works on one file with one word":
  lst-same-els(map-reduce([list: one-word], anagram-map, anagram-reduce),
    [list: tv("red", [list: "red"])], equal-values) is true
end

check "anagram-map and anagram-reduce work on one file":
  lst-same-els(map-reduce([list: anagram-file1], anagram-map, anagram-reduce),
    [list: tv("star", [list: "star", "rats"]), tv("tarts", [list: "tarts"])], 
    equal-values) is true
end

check "anagram-map and anagram-reduce work when there are duplicate words":
  lst-same-els(map-reduce([list: wc-file1], anagram-map, anagram-reduce),
    [list: tv("fish", [list: "fish"]), tv("red", [list: "red"]),
      tv("blue", [list: "blue"])], equal-values) is true
  lst-same-els(map-reduce([list: wc-file1, wc-file3], anagram-map, anagram-reduce),
    [list: tv("fish", [list: "fish"]), tv("red", [list: "red"]), 
      tv("blue", [list: "blue"]), tv("river", [list: "river"])], equal-values)
    is true
end

check "anagram-map and anagram-reduce work on multiple files":
  lst-same-els(map-reduce([list: anagram-file1, anagram-file2], anagram-map, 
      anagram-reduce),
    [list: tv("star", [list: "star", "rats", "arts"]), 
      tv("start", [list: "tarts", "start"]), tv("carts", [list: "carts"])],
    equal-values) is true
end

check "anagram-map and anagram-reduce are case-sensitive":
  lst-same-els(map-reduce([list: anagram-file1, uppercase-file1], anagram-map,
      anagram-reduce),
    [list: tv("star", [list: "star", "rats"]), tv("tarts", [list: "start", "tarts"]),
      tv("Star", [list: "Star"]), tv("rAts", [list: "rAts"])], equal-values)
    is true
end

check "recommend works when book-records is empty or title is not in book-records":
  recommend("the adventures of tom sawyer", [list: book-file1, book-file2]) is 
  tv(0, [list: ])
  recommend("dune", [list: ]) is tv(0, [list: ])
end

check "recommend works when there is no tie":
  recommend("dune", [list: book-file1, book-file2]) is 
  tv(2, [list: "the catcher in the rye"])
end

check "recommend works when there is a tie":
  recommend-equiv(recommend("catch-22", [list: book-file1, book-file2]),
    tv(1, [list: "to kill a mockingbird", "the catcher in the rye", "dune"])) is true
end

check "recommend is case-sensitive":
  recommend("Dune", [list: book-file1, book-file2, book-file3]) is tv(0, [list: ])
end

check "recommend works with extensive testing of various files and combinations":
  recommend-equiv(recommend("a", 
      [list: book-file4, book-file5, book-file6, book-file7]), 
    tv(2, [list: "b", "c"])) is true
  recommend-equiv(recommend("b", 
      [list: book-file4, book-file5, book-file6, book-file7]), 
    tv(2, [list: "a", "c"])) is true
  recommend-equiv(recommend("c", 
      [list: book-file4, book-file5, book-file6, book-file7]),
    tv(2, [list: "a", "b", "d"])) is true
  recommend-equiv(recommend("d", 
      [list: book-file4, book-file5, book-file6, book-file7]),
    tv(2, [list: "c"])) is true
  recommend-equiv(recommend("e", 
      [list: book-file4, book-file5, book-file6, book-file7]), 
    tv(1, [list: "a", "c", "b"])) is true
  recommend-equiv(recommend("f", 
      [list: book-file4, book-file5, book-file6, book-file7]), 
    tv(1, [list: "g"])) is true
  recommend-equiv(recommend("g", 
      [list: book-file4, book-file5, book-file6, book-file7]),
    tv(1, [list: "f"])) is true
end

check "popular-pairs works when book-records is empty":
  popular-pairs([list: ]) is tv(0, [list: ])
end

check "popular-pairs works with one file in book-records":
  recommend-equiv(popular-pairs([list: book-file2]),
    tv(1, [list: pair("dune", "the catcher in the rye"), 
        pair("dune", "the count of monte cristo"), 
        pair("the catcher in the rye", "the count of monte cristo")])) is true
end

check "popular-pairs does not care about order of books in BookPair":
  popular-pairs([list: book-file3]) is tv(1, [list: pair("dune", "catch-22")])
  popular-pairs([list: book-file3]) is tv(1, [list: pair("catch-22", "dune")])
end

check "popular-pairs works for multiple files and multiple pairs":
  recommend-equiv(popular-pairs([list: book-file1, book-file2, book-file3]),
    tv(2, [list: pair("dune", "the catcher in the rye"), 
        pair("dune", "catch-22")])) is true
  recommend-equiv(popular-pairs([list: book-file1, book-file3]),
    tv(2, [list: pair("dune", "catch-22")])) is true
end

check "popular-pairs works for extensive testing of various files and combinations":
  recommend-equiv(popular-pairs([list: book-file4]),
    tv(1, [list: pair("a", "b"), pair("a", "c"), pair("a", "d"), 
        pair("b", "c"), pair("b", "d"), pair("c", "d")])) is true
  recommend-equiv(popular-pairs([list: book-file5]), 
    tv(1, [list: pair("a", "c"), pair("a", "e"), pair("a", "b"), 
        pair("c", "e"), pair("c", "b"), pair("e", "b")])) is true
  recommend-equiv(popular-pairs([list: book-file6]), 
    tv(1, [list: pair("c", "d")])) is true
  recommend-equiv(popular-pairs([list: book-file7]), 
    tv(1, [list: pair("f", "g")])) is true
  recommend-equiv(popular-pairs([list: book-file6, book-file7]), 
    tv(1, [list: pair("c", "d"), pair("f", "g")])) is true
  recommend-equiv(popular-pairs([list: book-file4, book-file5]), 
    tv(2, [list: pair("a", "c"), pair("a", "b"), pair("c", "b")])) is true
  recommend-equiv(popular-pairs([list: book-file4, book-file5, book-file6, 
        book-file7]),
    tv(2, [list: pair("a", "c"), pair("a", "b"), pair("c", "b"), pair("c", "d")])) 
    is true
end