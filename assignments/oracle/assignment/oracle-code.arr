use context essentials2021
include shared-gdrive("oracle-definitions.arr", "1VIj7v7L2Qy8FSRO7dh2uZki_a1NDTFxh")

provide: is-valid, oracle end

include my-gdrive("oracle-common.arr")
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# You may write implementation-specific tests (e.g., of helper functions) in
# this file.
import sets as sets
import pick as pick

#|
   data Hire:
  | hire(company :: Number, candidate :: Number)
   end
|#

fun find-match(
    candidate :: Number, 
    matches :: Set<Hire>)
  -> Hire:
  doc: ```returns the match including the given candidate from a set of matches,
    assumes candidate is contained within matches```

  cases (Pick) matches.pick():
    | pick-none => raise("candidate must be in matches")
    | pick-some(m, r) => 
      if m.candidate == candidate:
        m
      else:
        find-match(candidate, r)
      end
  end
where:
  find-match(1, [sets.set: hire(1, 0), hire(0, 1)]) is hire(0, 1)
  find-match(0, [sets.set: hire(1, 0), hire(0, 1)]) is hire(1, 0)
  find-match(6, [sets.set: hire(23, 8), hire(9, 6)]) is hire(9, 6)
  find-match(4, [sets.set: hire(4, 4)]) is hire(4, 4)
  find-match(8, [sets.set: ]) raises "candidate must be in matches"
  find-match(2, [sets.set: hire(1, 0), hire(0, 1)]) raises "candidate must be in matches"
end

fun index-of(
    l :: List<Number>, 
    n :: Number) 
  -> Number:
  doc: "returns the index of the first instance of a given number in the list (n must be in list)"

  cases (List) l:
    | empty => raise("number not in list")
    | link(f, r) =>
      if f == n:
        0
      else:
        1 + index-of(r, n)
      end
  end
where:
  index-of([list: 1, 2, 3], 2) is 1
  index-of([list: 1, 2, 3], 1) is 0
  index-of([list: 0, 4, 2, 11], 11) is 3
  index-of([list: 0, 0, 0, 0, 0, 1], 1) is 5
  index-of([list: ], 1) raises "number not in list"
  index-of([list: 1, 2, 3], 5) raises "number not in list"
end

fun prefers-current(
    m :: Hire,
    other-company :: Number,
    companies :: List<List<Number>>,
    candidates :: List<List<Number>>)
  -> Boolean:
  doc: "checks if the candidate prefers their current company over another"

  candidates-prefrences = candidates.get(m.candidate)
  index-of(candidates-prefrences, m.company) < index-of(candidates-prefrences, other-company)
where:
  prefers-current(hire(0, 1), 1, 
    [list: [list: 0, 1], [list: 0, 1]], [list: [list: 0, 1], [list: 0, 1]]) is true
  prefers-current(hire(1, 0), 0, 
    [list: [list: 1, 0], [list: 0, 1]], [list: [list: 0, 1], [list: 0, 1]]) is false
  prefers-current(hire(0, 1), 1, 
    [list: [list: 1, 0], [list: 1, 0]], [list: [list: 0, 1], [list: 0, 1]]) is true
end

fun match-is-valid(
    m :: Hire, 
    companies :: List<List<Number>>,
    candidates :: List<List<Number>>,
    matches :: Set<Hire>)
  -> Boolean:
  doc:  ```checks if any candidate prefered by the company prefers 
    the other company more than their current match```

  comp-prefrences = companies.get(m.company)
  preferred-candidates = split-at(index-of(comp-prefrences, m.candidate), comp-prefrences).prefix
  current-matches = map(lam(n): find-match(n, matches) end, preferred-candidates)
  cases (List) current-matches:
    | empty => true
    | link(_, _) => 
      all(lam(h): prefers-current(h, m.company, companies, candidates) end, current-matches)
  end
where:
  match-is-valid(hire(0, 0), [list: [list: 0, 1], [list: 0, 1]], 
    [list: [list: 0, 1], [list: 0, 1]], 
    [sets.set: hire(1, 0), hire(0, 1)]) is true
  match-is-valid(hire(0, 1), [list: [list: 0, 1], [list: 0, 1]], 
    [list: [list: 0, 1], [list: 0, 1]], 
    [sets.set: hire(1, 0), hire(0, 1)]) is false
  match-is-valid(hire(1, 0), [list: [list: 1, 0], [list: 1, 0]], 
    [list: [list: 0, 1], [list: 0, 1]], 
    [sets.set: hire(1, 0), hire(0, 1)]) is true
  match-is-valid(hire(0, 1), [list: [list: 1, 0], [list: 1, 0]], 
    [list: [list: 0, 1], [list: 0, 1]], 
    [sets.set: hire(1, 0), hire(0, 1)]) is true
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

fun well-formed(
    matches :: Set<Hire>)
  -> Boolean:
  doc: "checks matches is formed as expected"

  r = range(0, matches.size())
  identical-contents(r, fold(lam(acc, c): link(c.company, acc) end, empty, matches.to-list())) 
  and
  identical-contents(r, fold(lam(acc, c): link(c.candidate, acc) end, empty, matches.to-list())) 
where:
  well-formed([sets.set: hire(0, 3), hire(1, 1), hire(2, 0), hire(3, 2)]) is true
  well-formed([sets.set: hire(0, 3), hire(1, 1), hire(2, 0), hire(3, 3)]) is false
  well-formed([sets.set: hire(21, 5)]) is false
  well-formed([sets.set: hire(0, 4), hire(1, 1), hire(2, 0), hire(4, 2)]) is false
  well-formed(sets.empty-list-set) is true
end

fun random-tester(
    num-tests :: Number, 
    list-len :: Number, 
    a-matchmaker :: (List<List<Number>>, 
      List<List<Number>> -> Set<Hire>))
  -> Boolean:
  doc: ```tests function 'a-matchmaker' 
    calls a generated input of length 'list-len', 'num-tests' times```

  if num-tests <= 0:
    true
  else:
    rand-num = num-random(list-len)
    companies = generate-input(rand-num)
    candidates = generate-input(rand-num)
    is-valid(companies, candidates, a-matchmaker(companies, candidates)) and 
    random-tester(num-tests - 1, list-len, a-matchmaker)
  end
where:
  random-tester(1, 2, matchmaker) is true
  random-tester(2, 3, matchmaker) is true
  random-tester(3, 0, matchmaker) is true
end

fun correct-matches(
    companies :: List<List<Number>>,
    candidates :: List<List<Number>>,
    matches :: Set<Hire>,
    original-matches :: Set<Hire>)
  -> Boolean:
  doc:```checks if the matches satisy the stable hiring problem```

  cases (Pick) matches.pick():
    | pick-none => true
    | pick-some(m, r) => 
      match-is-valid(m, companies, candidates, original-matches) and 
      correct-matches(companies, candidates, r, original-matches)
  end
where:
  correct-matches(empty, empty, 
    sets.empty-list-set, sets.empty-list-set) is true
  correct-matches([list: nl-0], [list: nl-0], 
    [sets.set: hire(0, 0)], [sets.set: hire(0, 0)]) is true
  same-s = [sets.list-set:hire(2, 2), hire(1, 1), hire(0,0)]
  correct-matches([list: nl-0-1-2, nl-0-1-2, nl-0-1-2], [list: nl-0-1-2, nl-0-1-2, nl-0-1-2], 
    same-s, same-s) is true
  wrong-s = [sets.list-set:hire(1, 2), hire(2, 1), hire(0,0)]
  correct-matches([list: nl-0-1-2, nl-0-1-2, nl-0-1-2], [list: nl-0-1-2, nl-0-1-2, nl-0-1-2], 
    wrong-s, wrong-s) is false
end

fun is-valid(
    companies :: List<List<Number>>,
    candidates :: List<List<Number>>,
    matches :: Set<Hire>)
  -> Boolean:
  doc:```evaluates if a set of matches is a valid solution 
   to the stable hiring problem based on the input```

  (matches.size() == companies.length()) and well-formed(matches) and 
  correct-matches(companies, candidates, matches, matches)
end

fun oracle(
    a-matchmaker :: (List<List<Number>>, List<List<Number>> -> Set<Hire>)) 
  -> Boolean:
  doc: "tests the efficacy  and accuracy of a given matchmaking function"  

  l-0 = [list: 0]
  l-0-1 = [list: 0, 1]
  l-1-0 = [list: 1, 0]
  l-0-1-2 = [list: 0, 1, 2]

  empty-case = is-valid(empty, empty, a-matchmaker(empty, empty))

  one-case = 
    is-valid([list: l-0], [list: l-0], 
      a-matchmaker([list: l-0], [list: l-0]))

  basic-case = 
    is-valid([list: l-1-0, l-0-1], [list: l-1-0, l-1-0], 
      a-matchmaker([list: l-1-0, l-1-0], [list: l-0-1, l-0-1]))

  all-same-case = 
    is-valid([list: l-0-1, l-0-1], [list: l-0-1, l-0-1], 
      a-matchmaker([list: l-0-1, l-0-1], [list: l-0-1, l-0-1]))

  each-different-case = 
    is-valid([list: l-0-1, l-1-0], [list: l-1-0, l-0-1], 
      a-matchmaker([list: l-0-1, l-1-0], [list: l-1-0, l-0-1]))

  each-same-case = 
    is-valid([list: l-1-0, l-1-0], [list: l-0-1, l-0-1], 
      a-matchmaker([list: l-1-0, l-1-0], [list: l-0-1, l-0-1]))

  three-same-case = 
    is-valid([list: l-0-1-2, l-0-1-2, l-0-1-2], [list: l-0-1-2, l-0-1-2, l-0-1-2], 
      a-matchmaker([list: l-0-1-2, l-0-1-2, l-0-1-2], [list: l-0-1-2, l-0-1-2, l-0-1-2]))


  empty-case and one-case and
  all-same-case and each-same-case and
  each-different-case and three-same-case and
  basic-case and random-tester(5, 5, a-matchmaker) and
  random-tester(5, 10, a-matchmaker) and random-tester(5, 20, a-matchmaker)
end

