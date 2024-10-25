use context essentials2021
include shared-gdrive("sortacle-definitions.arr", "1d6n7TSAQa_aTEqLyTXjHxFsdrQAt_lyq")

provide: generate-input, is-valid, oracle end

include my-gdrive("sortacle-common.arr")
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# You may write implementation-specific tests (e.g., of helper functions) in this file.

#|
data Person:
| person(name :: String, age :: Number)
end   
|#

fun random-nums(len :: Number, r :: Number)
  -> List<Number>:
  doc: "returns a list of random numbers"
  
  if len <= 0: empty
  else:
    link(num-random(r), random-nums((len - 1), r))
  end
where:
  random-nums(10, 10).length() is 10
  random-nums(0, 10) is empty
  all-true(map(lam(n): is-number(n) end, random-nums(23, 50))) is true
  random-nums(3, 100) satisfies is-link
  all-true(map(lam(n): (n >= 0) and (n <= 100) end, random-nums(20, 100))) is true
end

#tested elsewhere
fun generate-input(n :: Number)
  -> List<Person>:
  doc: "creates a list of randomly generated people"
  
  a-person = person(
    string-from-code-points(random-nums(num-random(100), 65535)),
    num-random(125))
  
  if n <= 0:
    empty
  else:
    link(a-person, generate-input(n - 1))
  end
end

fun is-member<T>(item :: T, l :: List<T>)
  -> Boolean:
  doc: "determines whether item is contained within list l"
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
    
fun remove-first<T>(item :: T, l :: List<T>)
  -> List<T>:
  doc: "removes the first instance of item from list l"
  
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
  
fun identical-contents<T>(l1 :: List<T>, l2 :: List<T>)
  -> Boolean:
  doc: "determines whether two lists contain exclusivley the same items"
  cases (List) l1:
    | empty =>
      if is-empty(l2):
        true
      else:
        false
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
end    
  
fun ages-are-ascending(people :: List<Person>)
  -> Boolean:
  
  cases (List) people:
    | empty => true
    | link(first, r) => 
      cases (List) r:
        | empty => true
        | link(second, _) =>
          if second.age >= first.age:
            ages-are-ascending(r)
          else:
            false
          end
      end
  end
where:
  ages-are-ascending([list: person("1", 4), person("2", 4), person("3", 29), person("4", 99)]) is true
  ages-are-ascending([list: person("2", 4), person("1", 4), person("3", 29), person("4", 99)]) is true
  ages-are-ascending([list: person("1", 4), person("2", 29), person("3", 8), person("4", 99)]) is false
  ages-are-ascending([list:]) is true
  ages-are-ascending([list: person("1", 50)]) is true
  
end            

#tested elsewhere
fun is-valid(original :: List<Person>, sorted :: List<Person>) 
  -> Boolean:
  doc: "determines whether list of people, original, is correctly sorted in ascending order of age" 
  identical-contents(original, sorted) and ages-are-ascending(sorted)
end

fun my-append<T>(l1 :: List<T>, l2 :: List<T>)
  -> List<T>:
  doc: "combines two lists to form a new list"
  cases (List) l1:
    | empty => l2
    | link(f, r) =>
      link(f, my-append(r, l2))
  end
where:
  my-append([list: "1", "2"], [list: "1"]) is [list: "1", "2", "1"]
  my-append([list: "1"], [list:]) is [list: "1"]
  my-append([list:], [list:]) is [list:]
  my-append([list: "1", "8"], [list: "5", "5"]) is [list: "1", "8", "5", "5"]
end

#tested elsewhere
fun oracle(sorter :: (List<Person> -> List<Person>))
  -> Boolean:
  doc: "determines if the function 'sorter' correctly sorts lists of people in ascending age order"
  
  input = 
    my-append(map(lam(n): generate-input(n) end, random-nums(50, 20)), #random tests
      [list: #hard coded tests
        [list:], #empty
        [list: person("p1", 10)], #one term
        [list: person("p1", 79), person("p1",109), person("p1", 18)], #same name
        [list: person("p1", 1), person("p2", 1), person("p3", 1), person("p4", 1)], #same ages
        [list: person("p1", 1), person("p1", 1), person("p1", 1)], #same name and age
        [list: person("p1", 100), person("p2", 50), person("p3", 10)], #descending
        [list: person("p1", 10), person("p2", 50), person("p3", 100)], #already sorted ascending
        [list: person("p1", 999999999), person("p2", 1000000000), person("p3", 999999998)], #large ages
        [list: person("p1", 0), person("p2", 0)], #0 years old
        [list: person("", 10), person("p1", 8), person("", 90)]]) #empty name
             
  all-true(map(lam(people): is-valid(people, sorter(people)) end, input)) #running tests
end
            
