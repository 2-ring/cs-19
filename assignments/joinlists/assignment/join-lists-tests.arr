use context essentials2021
include shared-gdrive("join-lists-definitions.arr", "1gNl8Rt88uWqpbv0Hx9Fkh6ajnNoDr164")

include my-gdrive("join-lists-common.arr")
import j-first, j-rest, j-length, j-nth, j-max, j-map, j-filter, j-reduce, j-sort
  from my-gdrive("join-lists-code.arr")
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# Write your examples and tests in here. These should not be tests of
# implementation-specific details (e.g., helper functions).

#j-first

check "j-first: standard functionality":
  j-first(natural-nums-3) is 1
  j-first(natural-nums-7) is 1
  j-first(random-nums-5) is 101
end

check "j-first: one term":
  j-first(one-term-num) is 8743
  j-first(one-term-string) is "Greetings Little One"
end

check "j-first: different data types":
  j-first(random-bools-4) is true
  j-first(random-lists-2) is [list: 5, 3, 1, 10]
  j-first(random-strings-3) is "Descend"
end

#j-rest

check "j-rest: standard functionality":
  j-rest(natural-nums-3) is [join-list: 2, 3]
  j-rest(natural-nums-7) is [join-list: 2, 3, 4, 5, 6, 7]
  j-rest(random-nums-5) is [join-list: 73, 55, 10, 11]
end

check "j-rest: one term":
  j-rest(one-term-num) is empty-join-list
  j-rest(one-term-string) is empty-join-list
end

check "j-rest: different data types":
  j-rest(random-bools-4) is [join-list: false, false, false,]
  j-rest(random-lists-2) is [join-list: [list: 19]]
  j-rest(random-strings-3) is [join-list: "to", "EARTH!!"]
end

#j-length

check "j-length: standard functionality":
  j-length(natural-nums-3) is 3
  j-length(natural-nums-7) is 7
  j-length(random-nums-5) is 5
end

check "j-length: one term":
  j-length(one-term-num) is 1
  j-length(one-term-string) is 1
end

check "j-length: different data types":
  j-length(random-bools-4) is 4
  j-length(random-lists-2) is 2
  j-length(random-strings-3) is 3
end

check "j-length: empty list":
  j-length(empty-join-list) is 0
end

#j-nth

check "j-nth: standard functionality":
  j-nth(natural-nums-3, 2) is 3
  j-nth(natural-nums-7, 5) is 6
  j-nth(random-nums-5, 0) is 101
end

check "j-nth: one term":
  j-nth(one-term-num, 0) is 8743
  j-nth(one-term-string, 0) is "Greetings Little One"
end

check "j-nth: different data types":
  j-nth(random-bools-4, 0) is true
  j-nth(random-lists-2, 1) is [list: 19]
  j-nth(random-strings-3, 2) is "EARTH!!"
end

#j-max

check "j-max: standard functionality":
  j-max(natural-nums-3, {(x,y): x < y}) is 1
  j-max(natural-nums-7, {(x,y): num-abs(5 - x) < num-abs(5 - y)}) is 5
  j-max(random-nums-5, {(x,y): x > y}) is 101
end

check "j-max: one term":
  j-max(one-term-num, {(x,y): x > y}) is 8743
  j-max(one-term-string, {(x,y): string-length(x) > string-length(y)}) is "Greetings Little One"
end

check "j-max: different data types":
  j-max(random-lists-2, {(x,y): x.length() < y.length()}) is [list: 19]
end

check "j-max: multiple maximums":
  string-length(j-max([join-list: "1234567", "Lucas", "Joy-Sad", "Hello"], 
      {(x,y): string-length(x) > string-length(y)})) is 7
  j-max([join-list: 10, 5, 6, 10, 5, 2, 10], {(x,y): x > y}) is 10
  j-max([join-list: empty-join-list, [join-list: 89, 3], [join-list: 7], empty-join-list], 
    {(x,y): x.length() < y.length()}).length() is 0
end

#j-map

check "j-map: standard functionality":
  j-map({(x): x + 1}, natural-nums-3) is [join-list: 2, 3, 4]
  j-map({(x): x * x}, natural-nums-7) is [join-list: 1, 4, 9, 16, 25, 36, 49]
  j-map({(x): x / 2}, random-nums-5) is [join-list: 50.5, 36.5, 27.5, 5, 5.5]
end

check "j-map: one term":
  j-map({(x): x - 8743}, one-term-num) is [join-list: 0]
  j-map({(x): ""}, one-term-string) is [join-list: ""]
end

check "j-map: different data types":
  j-map({(x): not(x)}, random-bools-4) is [join-list: false, true, true, true]
  j-map({(x): append(x, [list: 21]).drop(1)}, random-lists-2) 
    is [join-list: [list: 3, 1, 10, 21], [list: 21]]  
  j-map({(x): string-to-upper(x)}, random-strings-3) is [join-list: "DESCEND", "TO", "EARTH!!"]
end

check "j-map: empty list":
  j-map({(x): x + 1}, empty-join-list) is empty-join-list
end

#j-filter

check "j-filter: standard functionality":
  j-filter({(x): x > 1}, natural-nums-3) is [join-list: 2, 3]
  j-filter({(x): x == (x * x)}, natural-nums-7) is [join-list: 1]
  j-filter({(x): num-is-integer(x / 2)}, random-nums-5) is [join-list: 10]
end

check "j-filter: one term":
  j-filter({(x): x == 8742}, one-term-num) is empty-join-list
  j-filter({(x): string-length(x) == 20}, one-term-string) is [join-list: "Greetings Little One"]
end

check "j-filter: different data types":
  j-filter({(x): not(x)}, random-bools-4) is [join-list: false, false, false]
  j-filter({(x): x.length() < 3}, random-lists-2) is  [join-list: [list: 19]] 
  j-filter({(x): x == string-to-upper(x)}, random-strings-3) is [join-list: "EARTH!!"]
end

check "j-filter: empty list":
  j-filter({(x): x + 1}, empty-join-list) is empty-join-list
end

#j-reduce

check "j-reduce: standard funcitonality":
  j-reduce({(x,y): x * y}, natural-nums-3) is 6
  j-reduce({(x,y): x + y}, natural-nums-7) is 28
end

check "j-filter: different data types":
  j-reduce({(x,y): string-append(x,y)}, random-strings-3) is "DescendtoEARTH!!"
  j-reduce({(x,y): x or y}, random-bools-4) is true
end

check "j-reduce: one term":
  j-reduce({(x,y): x - y}, one-term-num) is 8743
end

#j-sort

#helper functions

fun all-true(bools :: List<Boolean>) -> Boolean:
  doc: "Determines if all booleans in a list are 'true'."
  fold(lam(acc, bool): acc and bool end, true, bools)
where:
  all-true(empty) is true
  all-true([list: true]) is true
  all-true([list: true, false, true]) is false
  all-true([list: true, true, true, true]) is true
  all-true([list: false, false]) is false
end

fun random-nums(len :: Number, r :: Number) -> JoinList<Number>:
  doc: "Returns a JoinList of length 'len' containing random numbers between 0 and r."
  if len <= 0: 
    empty-join-list
  else:
    [join-list: num-random(r)].join(random-nums((len - 1), r))
  end
where:
  j-length(random-nums(10, 10)) is 10
  random-nums(0, 10) is empty-join-list
  j-reduce({(x,y): x and y}, j-map({(n): is-number(n)}, random-nums(23, 50))) is true
  random-nums(3, 100) satisfies is-non-empty-jl
  j-reduce({(x,y): x and y}, j-map({(n): (n >= 0) and (n <= 100)}, random-nums(20, 100))) is true
end

fun is-member<A>(item :: A, l :: List<A>)-> Boolean:
  doc: "Determines whether value 'item' is contained within list 'l'."
  cases (List) l:
    | empty => false
    | link(f, r) =>
      if f == item:
        true
      else:
        is-member(item, r)
      end
  end
where:
  is-member("??", empty) is false
  is-member(1, [list: 1]) is true
  is-member(1, [list: 3, 2, 1]) is true
  is-member("1", [list: "22", "1", "12", "1"]) is true
  is-member("o[][qd", [list: "totally", "normal", "stuff"]) is false
  is-member("CAPS", [list: "caps", "are", "overated"]) is false
end
    
fun remove-first<A>(item :: A, l :: List<A>) -> List<A>:
  doc: "Removes the first instance of value 'item' from list 'l'."
  cases (List) l:
    | empty => empty
    | link(f, r) =>
      if f == item:
        r
      else:
        link(f, remove-first(item, r))
      end
  end
where:
  remove-first(1, [list: 1, 1, 1]) is [list: 1, 1]
  remove-first("1", [list: "2", "1", "4", "3"]) is [list: "2", "4", "3"]
  remove-first("8", [list: "7", "9", "10"]) is [list: "7", "9", "10"]
  remove-first("8", [list: "7", "9", "10", "8"]) is [list: "7", "9", "10"] 
  remove-first("??", empty)
  remove-first(8, [list: 9, 2, 4, 8, 9, 8]) is [list: 9, 2, 4, 9, 8]
end

fun identical-contents<A>(l1 :: List<A>, l2 :: List<A>) -> Boolean:
  doc: "Determines whether two lists contain exclusivley the same items."
  cases (List) l1:
    | empty =>
      cases (List) l2:
        | empty => true
        | link(_, _) => false
      end
    | link(f, r) =>
      if is-member(f, l2):
        identical-contents(r, remove-first(f, l2))
      else:
        false
      end
  end
where:
  identical-contents([list: "1", "2", "4", "3"], [list: "2", "1", "4", "3"]) is true
  identical-contents([list: "1", "2", "4", "3"], [list: "2", "1", "4", "3", "8"]) is false
  identical-contents([list: "1", "2", "4"], [list: "2", "1", "4", "3"]) is false
  identical-contents([list:], [list:]) is true
  identical-contents([list: 4, 6, 4, 6, 3, 4], [list: 4, 4, 4, 6, 3, 6]) is true
  identical-contents([list: 4, 6, 4, 3, 3, 4], [list: 4, 4, 4, 6, 3, 6]) is false
end    

#tester functions

fun is-sorted<A>(cmp-fun :: (A, A -> Boolean), sorted :: List<A>) -> Boolean:
  doc: ```Checks if a list is sorted such that if the comparator 'cmp-fun' returns 
       true, then the first argument to the comparator should come before the second 
       argument in the list 'sorted'.```
  fold({(acc, curr):
      {acc.{0} and #produces boolean for if list is sorted so far
        (cmp-fun(acc.{1}, curr) or #if in correct order or...
          not(cmp-fun(curr, acc.{1}))); #if terms have same value
        curr}}, #passes current term into the accumulator
    {true; sorted.first}, sorted.rest).{0} #parameters for fold
where:
  is-sorted({(x,y): x > y}, [list: 3, 2, 1]) is true
  is-sorted({(x,y): string-length(x) < string-length(y)}, 
    [list: "same", " len", "word"]) is true
  is-sorted({(x,y): string-length(x) < string-length(y)}, 
    [list: "get", "bigger", "and bigger"]) is true
  is-sorted({(x,y): x > y}, [list: 1, 8, 3, 2, 1]) is false
  is-sorted({(x,y): x < y}, [list: 1, 3, 2, 1]) is false
  is-sorted({(x,y): (x * x) > (y * y)}, [list: -9, 3, -2, 1, 1, -1]) is true
end

fun sort-is-valid<A>(cmp-fun :: (A, A -> Boolean), original :: JoinList<A>) -> Boolean:
  doc: ```Tests that the JoinList 'original' is a valid sorted solution 
       according to the comparison function cmp-fun.```
  sorted = j-sort(cmp-fun, original)
  original-as-list = join-list-to-list(original)
  sorted-as-list = join-list-to-list(sorted)
  identical-contents(original-as-list, sorted-as-list) and is-sorted(cmp-fun, sorted-as-list)
end

fun sort-random-tests<A>() -> Boolean:
  doc: "Genrates random input and tests function j-sort with it."
  random-input = map({(x): random-nums(20, 100)}, range(0, 10)) #random inputs
  all-true( #checks sorter-is-valid is always true for input
    map({(nums): sort-is-valid({(x,y): x > y}, nums)}, random-input)) #calls sorter on input
end

check "j-sort: ten random tests":
  sort-random-tests() is true
end

check "j-sort: elements with the same values":
  sort-is-valid(
    {(x,y): string-length(x) > string-length(y)}, 
    strings-some-same-len) is true
  sort-is-valid(
    {(x,y): string-length(x) > string-length(y)}, 
    strings-all-same-len) is true
  sort-is-valid(
    {(x,y): length(x) < length(y)}, 
    sorted-by-length) is true
end

check "j-sort: other cmp-funs":
  sort-is-valid(
    {(x,y): (x * x) > (y * y)}, 
    sorted-by-squares) is true
  sort-is-valid(
    {(x,y): x.first > y.first}, 
    sorted-by-first) is true
  sort-is-valid(
    {(x,y): x.first > y.first}, 
    random-lists-2) is true
end

check "j-sort: wrong sort direction":
  sort-is-valid(
    {(x,y): x > y}, 
    natural-nums-7) is true
end
