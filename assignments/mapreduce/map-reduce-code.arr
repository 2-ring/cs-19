use context essentials2021
include shared-gdrive("map-reduce-definitions.arr", "10VnNW4MbHmHsSh05fj365dbzoVItGQbr")

provide: map-reduce, anagram-map, anagram-reduce, recommend, popular-pairs end

include my-gdrive("map-reduce-common.arr")
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# You may write implementation-specific tests (e.g., of helper functions)
# in this file.

## A. Your map-reduce definition

#helpers
fun group-pairs<P, Q>(
    grouped :: List<P>, 
    to-group :: List<Tv-pair<P, Q>>) 
  -> List<Tv-pair<P, List<Q>>>:
  doc: ```Combines each pair with the same tag into a single 
       Tv-pair, with their values in a list.```
  cases (List) to-group:
    | empty => empty
    | link(curr, rest) =>
      if member(grouped, curr.tag): #if already processed
        group-pairs(grouped, rest) #skip
      else:
        now-grouped = link(curr.tag, grouped)
        link(
          tv(curr.tag, values-by-tag(curr.tag, to-group)), #combined tag
          group-pairs(now-grouped, rest)) #recursive call
      end
  end
where:
  group-pairs(empty, 
    [list: tv(1, 1), tv(3, 1), tv(1, 3), tv(1, 2), tv(2, 1)]) 
    is [list: tv(1, [list: 1, 3, 2]), tv(3, [list: 1]), tv(2, [list: 1])]
  group-pairs(empty, 
    [list: 
      tv("arst", "star"), 
      tv("arst", "rats"), 
      tv("arstt", "tarts"), 
      tv("arst", "arts"), 
      tv("arstt", "start"), 
      tv("acrst", "carts")]) is 
  [list: 
    tv("arst", [list: "star", "rats", "arts"]), 
    tv("arstt", [list: "tarts", "start"]), 
    tv("acrst", [list: "carts"])]
end

fun values-by-tag<P, Q>(tag :: P, curr-list :: List<Tv-pair<P, Q>>) -> List<Q>:
  doc: ```Finds all values associated with the given tag.```
  cases (List) curr-list:
    | empty => empty
    | link(f, r) =>
      if (f.tag == tag):
        link(f.value, values-by-tag(tag, r))
      else:
        values-by-tag(tag, r)
      end
  end
where:
  values-by-tag("arst", [list: 
      tv("arst", "star"), 
      tv("arst", "rats"), 
      tv("arstt", "tarts")]) is [list: "star", "rats"]
  values-by-tag("belu", [list: 
      tv("belu", "blue"), 
      tv("fhis", "fish")]) is [list: "blue"]
  values-by-tag("NONE", [list: 
      tv("belu", "blue"), 
      tv("fhis", "fish")]) is empty
end

#main
fun map-reduce<A, P, Q, R>(
    input :: List<A>,
    mapper :: (A -> List<Tv-pair<P, Q>>),
    reducer :: (Tv-pair<P, List<Q>> -> Tv-pair<P, R>))
  -> List<Tv-pair<P, R>>:
  doc: ```As described in the handout.```
  in-pairs = fold({(acc, i): acc.append(mapper(i))}, empty, input)
  grouped = group-pairs(empty, in-pairs)
  map(reducer, grouped)
end

### B. Your anagram implementation  

#helpers
fun sort-string(s :: String) -> String:
  doc: ```Sorts the given String by the Unicode representation 
       of each charecter.```
  string-from-code-points( #back to string
    sort( #sorts codepoints
      string-to-code-points(s))) #converts each charecter to Unicode
where:
  sort-string("'With, PUNCTUATION TOO!!!...") is "  !!!',...ACINNOOOPTTTUUWhit"
  sort-string("") is ""
  sort-string("As easy as: 123.") is "   .123:Aaaesssy"
end

#main
fun anagram-map(input :: Tv-pair<String, String>) 
  -> List<Tv-pair<String, String>>:
  doc: ```Splits the file into words. For each word, finds a value 
       indicative of anagram group and uses it to create a Tv-pair.```
  words = string-split-all(input.value, " ") #get every unique word
  map({(w): #for each word
      anagram-group = sort-string(w) #find a value indicative of anagram group
      tv(anagram-group, w)}, words) #and make a tv-pair
where:
  anagram-map(one-word) is [list: tv("der", "red")]
  anagram-map(wc-file1) is [list: 
    tv("der", "red"), 
    tv("fhis", "fish"), 
    tv("belu", "blue"), 
    tv("fhis", "fish")]
  anagram-map(anagram-file1) is [list: 
    tv("arst", "star"), 
    tv("arst", "rats"), 
    tv("arstt", "tarts")]
end

fun anagram-reduce(input :: Tv-pair<String, List<String>>)
  -> Tv-pair<String, List<String>>:
  doc: ```Removes any repeated words from the anagram group
       and returns the updated Tv-pair.```
  tv(input.tag, distinct(input.value))
where:
  anagram-reduce(tv("der", [list: "red"])) is tv("der", [list: "red"])
  anagram-reduce(tv("fhis", [list: "fish", "fish"])) is tv("fhis", [list: "fish"])
  anagram-reduce(tv("arst", [list: "star", "rats", "arts", "rats"])) is
  tv("arst", [list: "star", "arts", "rats"])
end

## C. Your Nile implementation

#helpers
fun make-recommendation<T>(
    with-freq :: List<Tv-pair<T, Number>>) 
  -> Tv-pair<Number, List<T>>:
  doc: ```Given a list of Tv-pairs with a tag and a number
       denoting the tag's frequency, find the max frequency
       across all Tv-pairs and all tags with that frequency. 
       Then return a Tv-pair combining both pieces of 
       information. Precondition: with-freq must be non-empty.```
  max-freq = fold({(acc, p): num-max(acc, p.value)}, 0, with-freq)
  max-tags = map({(p): p.tag},
    filter({(p): p.value == max-freq}, with-freq))
  tv(max-freq, max-tags)
where:
  make-recommendation([list: tv("Dune", 5)]) is tv(5, [list: "Dune"]) 
  make-recommendation([list: tv("Dune", 2), tv("Catch-22", 1)]) is
  tv(2, [list: "Dune"])
  make-recommendation([list: tv("Dune", 2), tv("Catch-22", 2)]) is
  tv(2, [list: "Dune", "Catch-22"])
end

fun nile-reduce<T>(grouped-pair :: Tv-pair<T, List<Number>>)
  -> Tv-pair<T, Number>:
  doc: ```Given a Tv-pair with a tag and a list of 1's,
       return a new Tv-pair with that tag and the length
       of the value list.```
  tv(grouped-pair.tag, grouped-pair.value.length())
where:
  nile-reduce(tv("Dune", [list: 1, 1, 1])) is tv("Dune", 3)
  nile-reduce(tv("Catch-22", [list: 1])) is tv("Catch-22", 1)
  nile-reduce(tv(pair("Dune", "Catch-22"), [list: 1, 1, 1, 1])) is
    tv(pair("Dune", "Catch-22"), 4)
end

## recommend ##

#helpers
fun recommend-map(file :: Tv-pair<String, List<String>>)
  -> List<Tv-pair<String, Number>>:
  doc: ```Creates a Tv-pair for each title in the given file which 
       contains it and the number 1.```
  map({(title): tv(title, 1)}, file.value)
where:
  recommend-map(book-file1) is [list: 
    tv("to kill a mockingbird", 1), 
    tv("the catcher in the rye", 1), 
    tv("catch-22", 1), 
    tv("dune", 1)]
  recommend-map(book-file2) is [list: 
    tv("dune", 1), 
    tv("the catcher in the rye", 1), 
    tv("the count of monte cristo", 1)]
end

#main
fun recommend(title :: String, book-records :: List<Tv-pair<String, List<String>>>)
  -> Tv-pair<Number, List<String>>:
  doc: ```As described in the handout.```
  relevant = filter({(file): member(file.value, title)}, book-records)
  without-title = map({(file): tv(file.tag, remove(file.value, title))}, relevant)
  with-freq = map-reduce(without-title, recommend-map, nile-reduce)  
  make-recommendation(with-freq)
end

## popular-pairs ##

#helpers
fun pair-with-all(
    title :: String, 
    other-titles :: List<String>) 
  -> List<BookPair>:
  doc: ```Creates and return a list containing BookPairs of 
       the title and each title in other-titles.
       Precondition: title is not in other-titles.```
  cases (List) other-titles:
    | empty => empty
    | link(pair-with, rest-titles) =>
      new-pair = 
        if pair-with > title:
          pair(pair-with, title)
        else:
          pair(title, pair-with)
        end
      link(new-pair, pair-with-all(title, rest-titles))
  end
where:
  pair-with-all("1", empty) is empty
  pair-with-all("1", [list: "2", "3"])
    is [list: pair("2", "1"), pair("3", "1")]
  pair-with-all("Dune", [list: "To kill a mockingbird", 
      "The catcher in the rye", "Catch-22"]) is [list: 
    pair("To kill a mockingbird", "Dune"), pair("The catcher in the rye", "Dune"),
    pair("Dune", "Catch-22")]
end

fun get-pairs(titles :: List<String>)
  -> List<BookPair>:
  doc: ```Returns a list of BookPairs, representing all the unique 
       pairs of Strings in the given List.```
  cases (List) titles:
    | empty => empty
    | link(f, r) => 
      pair-with-all(f, r) + get-pairs(r)
  end
where:
  get-pairs([list: "1", "2", "3"])
    is [list: pair("2", "1"), pair("3", "1"), pair("3", "2")]
  get-pairs(empty) is empty
  get-pairs(book-file2.value) is [list: 
    pair("the catcher in the rye", "dune"), 
    pair("the count of monte cristo", "dune"), 
    pair("the count of monte cristo", "the catcher in the rye")]
end

fun popular-map(file :: Tv-pair<String, List<String>>)
  -> List<Tv-pair<BookPair, Number>>:
  doc: ```Finds every unique BookPair contained with the given file, and 
       for each creates a Tv-pair which contains it and the number 1.```
  pairs = get-pairs(file.value)
  map({(p): tv(p, 1)}, pairs)
where:
  popular-map(book-file2) is [list: 
    tv(pair("the catcher in the rye", "dune"), 1), 
    tv(pair("the count of monte cristo", "dune"), 1), 
    tv(pair("the count of monte cristo", "the catcher in the rye"), 1)]
  popular-map(book-file3) is [list: tv(pair("dune", "catch-22"), 1)]
end

#main
fun popular-pairs(book-records :: List<Tv-pair<String, List<String>>>) 
  -> Tv-pair<Number, List<BookPair>>:
  doc: ```As described in the handout.```
  with-freq = map-reduce(book-records, popular-map, nile-reduce)  
  make-recommendation(with-freq)
end