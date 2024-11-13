use context essentials2021
include shared-gdrive("map-reduce-definitions.arr", "10VnNW4MbHmHsSh05fj365dbzoVItGQbr")

provide: *, type * end
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# Write data bindings here that you'll need for tests in both map-reduce-code.arr and map-reduce-tests.arr

# word count examples for map-reduce testing
one-word = tv("one-word.txt", "red")
wc-file1 = tv("file1.txt", "red fish blue fish")
wc-file2 = tv("file2.txt", "fish into the blue river")
wc-file3 = tv("file3.txt", "red river blue fish")

anagram-file1 = tv("words1.txt", "star rats tarts")
anagram-file2 = tv("words2.txt", "arts start carts")
uppercase-file1 = tv("upperwords1.txt", "Star rAts start")

book-file1 = tv("books1.txt", [list: "to kill a mockingbird", 
    "the catcher in the rye", "catch-22", "dune"])
book-file2 = tv("books2.txt", [list: "dune", "the catcher in the rye", 
    "the count of monte cristo"])
book-file3 = tv("books3.txt", [list: "dune", "catch-22"])
book-file4 = tv("books4.txt", [list: "a", "b", "c", "d"])
book-file5 = tv("books5.txt", [list: "a", "c", "e", "b"])
book-file6 = tv("books6.txt", [list: "c", "d"])
book-file7 = tv("books7.txt", [list: "f", "g"])

# testing functions
fun equal-values(tv-1 :: Tv-pair<String, List<String>>, 
    tv-2 :: Tv-pair<String, List<String>>) -> Boolean:
  doc: "returns true if the anagram lists of tv-1 and tv-2 are equal"
  lst-same-els(tv-1.value, tv-2.value, lam(x, a): x == a end)
end