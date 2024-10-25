use context essentials2021
include shared-gdrive("sortacle-definitions.arr", "1d6n7TSAQa_aTEqLyTXjHxFsdrQAt_lyq")

include my-gdrive("sortacle-common.arr")
import generate-input, is-valid, oracle
from my-gdrive("sortacle-code.arr")
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# Write your examples and tests in here. These should not be tests of implementation-specific details (e.g., helper functions).

#testing generate-input

check "correct length":
  generate-input(10).length() is 10
end
 
check "empty":
  generate-input(0) is empty
end

check "all terms are people":
  all-true(map(lam(p): is-person(p) end, generate-input(15))) is true
end

check "all terms have ages":
  all-true(map(lam(p): is-number(p.age) end, generate-input(15))) is true
end

check "all terms have ages within expected range":
  all-true(map(lam(p): (p.age >= 0) and (p.age <= 125) end, generate-input(15))) is true
end

check "all terms have valid names":
  all-true(map(lam(p): is-string(p.name) end, generate-input(15))) is true
end

#testing is-valid

check "standard functionality":
  is-valid(
    [list: person("1", 2), person("2", 3), person("3", 1)], 
    [list: person("3", 1), person("1", 2), person("2", 3)]) is true
end

check "changed name":
  is-valid(
    [list: person("1", 2), person("2", 3), person("3", 1)], 
    [list: person("3", 1), person("1", 2), person("4", 3)]) is false
  is-valid(
    [list: person("1", 2), person("2", 3), person("3", 1)], 
    [list: person("72874312", 1), person("1", 2), person("2", 3)]) is false
end

check "changed age":
  is-valid(
    [list: person("1", 2), person("2", 3), person("3", 1)], 
    [list: person("1", 2), person("2", 4), person("3", 1)]) is false
  is-valid(
    [list: person("1", 5), person("2", 3), person("3", 1)], 
    [list: person("1", 2), person("2", 3), person("3", 1)]) is false
end

check "missing term":
  is-valid(
    [list: person("1", 65), person("2", 3), person("3", 1)], 
    [list: person("3", 1), person("2", 3)]) is false
end

check "added term":
  is-valid(
    [list: person("1", 65), person("2", 3)], 
    [list: person("1", 65), person("2", 3), person("3", 1)]) is false
  is-valid(
    [list: person("1", 65)], 
    [list: person("1", 65), person("4", 10)]) is false
end

check "completely different lists":
  is-valid(
    [list: person("1", 2), person("2", 3), person("3", 1)], 
    [list: person("4", 5), person("5", 6), person("6", 7)]) is false
end

check "all the same term":
  is-valid(
    [list: person("Roger", 35), person("Roger", 35), person("Roger", 35)], 
    [list: person("Roger", 35), person("Roger", 35), person("Roger", 35)]) is true
end

check "multiple of the same name":
  is-valid(
    [list: person("Joe", 2), person("Joe", 3), person("Joe", 1)], 
    [list: person("Joe", 1), person("Joe", 2), person("Joe", 3)]) is true
  is-valid(
    [list: person("Elsie", 78), person("Fred", 16), person("Elsie", 21)], 
    [list: person("Fred", 16), person("Elsie", 21), person("Elsie", 78)]) is true
end

check "multiple of the same age":
  is-valid(
    [list: person("1", 34), person("2", 88), person("3", 88)], 
    [list: person("1", 34), person("2", 88), person("3", 88)]) is true
  is-valid(
    [list: person("1", 34), person("2", 88), person("3", 88)], 
    [list: person("1", 34), person("3", 88), person("2", 88)]) is true
end

check "empty list":
  is-valid(
    empty, 
    empty) is true
  is-valid(
    empty,
    [list: person("1", 1)]) is false
end

check "one term":
  is-valid(
    [list: person("1", 1)],
    [list: person("1", 1)]) is true
  is-valid(
    [list: person("1", 1)],
    [list: person("1", 4)]) is false
end


#testing oracle

#the correct sorter given to us
fun correct-sorter(people :: List<Person>) 
  -> List<Person>:
  doc: ```consumes a list of people and produces a list of people
       that are sorted by age in ascending order.``` 

  sort-by(people,
    lam(p1, p2): p1.age < p2.age end,
    lam(p1, p2): p1.age == p2.age end)

where:
  cjordan3 = person("Connor", 18)
  cli135   = person("Danny", 65)
  kreyes7  = person("Kyle", 32)

  correct-sorter(empty) is empty
  correct-sorter([list: cli135]) is [list: cli135]
  correct-sorter([list: cli135, cjordan3]) is [list: cjordan3, cli135]
  correct-sorter([list: cjordan3, cli135]) is [list: cjordan3, cli135]
  correct-sorter([list: cjordan3, cli135, kreyes7]) is [list: cjordan3, kreyes7, cli135]
end

#my correct sorter
fun sort-by-age(people :: List<Person>)
  -> List<Person>:
  doc: "sorts a list of people in ascending order of age"
  cases (List) people:
    | empty => empty
    | link(f, r) => insert-by-age(f, sort-by-age(r))
  end
end

fun insert-by-age(p :: Person, l :: List<Person>)
  -> List<Person>:
  doc: "inserts a person by age into correctly into an ascending list"
  cases (List) l:
    | empty => [list: p]
    | link(f, r) =>       
      if p.age > f.age:
        link(f, insert-by-age(p, r))              
        else:
        link(p, l)
        end
  end
end

#wrong sorters

fun return-same(people :: List<Person>)
  -> List<Person>:
  doc: "returns the list unchanged without sorting"
  people
end

fun sort-descending(people :: List<Person>) 
  -> List<Person>:
  doc: "sorts the list of people in descending order of age"
  sort-by(people,
    lam(p1, p2): p1.age > p2.age end,
    lam(p1, p2): p1.age == p2.age end)
end

fun random-people(people :: List<Person>) 
  -> List<Person>:
  doc: "generates a random list of people with the same length as the input list"
  generate-input(people.length())
end
  
fun drop-randomly(people :: List<Person>) 
  -> List<Person>:
  doc: "randomly drops some people from the list"
  people.drop(num-random(people.length()))
end
  
fun add-one-random(people :: List<Person>) 
  -> List<Person>:
  doc: "adds one random person to the beginning of the list"
  link(generate-input(1), people)
end
  
fun return-empty(people :: List<Person>) 
  -> List<Person>:
  doc: "returns an empty list regardless of the input"
  empty
end

fun sort-by-name(people :: List<Person>) 
  -> List<Person>:
  doc: "sorts the list by name instead of age"
  sort-by(people, 
    lam(p1, p2): p1.name < p2.name end, 
    lam(p1, p2): p1.name == p2.name end)
end

fun reverse-correct(people :: List<Person>) 
  -> List<Person>:
  doc: "sorts the list correctly but then reverses the order"
  reverse(correct-sorter(people))
end

fun return-shuffled(people :: List<Person>) 
  -> List<Person>:
  doc: "shuffles the list"
  shuffle(people)
end

check 'true case':
  oracle(correct-sorter) is true
  oracle(sort-by-age) is true
end

check 'false case':
  oracle(return-same) is false
  oracle(sort-descending) is false
  oracle(random-people) is false
  oracle(drop-randomly) is false
  oracle(add-one-random) is false
  oracle(return-empty) is false
  oracle(sort-by-name) is false
  oracle(reverse-correct) is false
  oracle(return-shuffled) is false
end