use context essentials2021
include shared-gdrive("oracle-definitions.arr", "1VIj7v7L2Qy8FSRO7dh2uZki_a1NDTFxh")

provide: *, type * end
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# Write data bindings here that you'll need for tests in both oracle-code.arr
# and oracle-tests.arr
import sets as sets
import pick as pick
type Set = sets.Set
type Pick = pick.Pick

nl-0 = [list: 0]
nl-0-1 = [list: 0, 1]
nl-1-0 = [list: 1, 0]
nl-0-1-2 = [list: 0, 1, 2]

fun swap-inputs(
		companies :: List<List<Number>>,
		candidates :: List<List<Number>>) 
	-> Set<Hire>:
	doc: "swaps the inputs of the given companies and candidates"
	matchmaker(candidates, companies)
end

fun random-matches(
		companies :: List<List<Number>>,
		candidates :: List<List<Number>>) 
	-> Set<Hire>:
	doc: "returns a list of randomly generated matches"

	sets.list-to-set(map2(
			lam(co, ca): hire(co, ca) end, 
			shuffle(range(0, companies.length())), 
			shuffle(range(0, candidates.length()))))
end

fun add-random(
		companies :: List<List<Number>>,
		candidates :: List<List<Number>>) 
	-> Set<Hire>:
	doc: "adds a random hire to the correct solution"

	list-len = companies.length()
	matchmaker(companies, candidates).add(hire(num-random(list-len), num-random(list-len)))
end

fun remove-random(
		companies :: List<List<Number>>,
		candidates :: List<List<Number>>) 
	-> Set<Hire>:
	doc: "removes a random hire from the correct solution"
	matches = matchmaker(companies, candidates)
	cases (Pick) matches.pick():
		| pick-none => sets.empty-list-set
		| pick-some(m, r) => r
	end
end

# shuffle-companies

fun shuffle-companies(
	companies :: List<List<Number>>,
	candidates :: List<List<Number>>)
  -> Set<Hire>:
	doc: "randomly shuffles companies then calls correct function"

	matchmaker(shuffle(companies), candidates)
end

# shuffle-candidates

fun shuffle-candidates(
	companies :: List<List<Number>>,
	candidates :: List<List<Number>>)
  -> Set<Hire>:
	doc: "randomly shuffles candidates then calls correct function"

	matchmaker(companies, shuffle(candidates))
end

# swap-within-match

fun swap-within-match(
	companies :: List<List<Number>>,
	candidates :: List<List<Number>>)
  -> Set<Hire>:
	doc: "swaps the company and candidate within one match of the correct solution"

	matches = matchmaker(companies, candidates)
	cases (Pick) matches.pick():
		| pick-none => sets.empty-list-set
    | pick-some(m, r) => r.add(hire(m.candidate, m.company))
	end
end

# modify-a-match

fun modify-a-match(
	companies :: List<List<Number>>,
	candidates :: List<List<Number>>)
  -> Set<Hire>:
	doc: "randomises the company field in a random match in the correct solution"

	matches = matchmaker(companies, candidates)
	cases (Pick) matches.pick():
		| pick-none => sets.empty-list-set
    | pick-some(m, r) => r.add(hire(num-random(companies.length()), m.candidate))
	end
end

#swap-two-matches

fun insert(
    index :: Number,
    value :: List<Number>,
    l :: List<List<Number>>) -> List<List<Number>>:
  cases (List) l:
    | empty => empty
    | link(f, r) =>
      if index == 0:
        link(value, link(f, r))
      else:
        link(f, insert(index - 1, value, r))
      end
  end
end

fun my-remove(
    index :: Number,
    l :: List<Hire>) -> List<Hire>:
  cases (List) l:
    | empty => empty
    | link(f, r) =>
      if index == 0:
        r
      else:
        link(f, my-remove(index - 1, r))
      end
  end
end


fun swap-two-matches(
    companies :: List<List<Number>>,
    candidates :: List<List<Number>>)
  -> Set<Hire>:
  matches = matchmaker(companies, candidates).to-list()
  if matches.length() == 0:
    sets.empty-set
  else if matches.length() == 1:
    matchmaker(companies, candidates)
  else:
    mixed-matches = shuffle(matches)
    hire1 = mixed-matches.get(0)
    hire2 = mixed-matches.get(1)
    new-hire1 = hire(hire1.company, hire2.candidate)
    new-hire2 = hire(hire2.company, hire1.candidate)
    sets.list-to-set(link(new-hire2, link(new-hire1 , matches.remove(hire1).remove(hire2))))
  end
end

#swap-two-companies

fun swap-two-companies(
    companies :: List<List<Number>>,
    candidates :: List<List<Number>>)
  -> Set<Hire>:
  if companies.length() == 0:
    sets.empty-set
  else if companies.length() == 1:
    matchmaker(companies, candidates)
  else:
    mixed-companies = shuffle(companies)
    pref1 = mixed-companies.get(0)
    pref2 = mixed-companies.get(1)
    removed-companies = remove-element<Number>(remove-element<Number>(companies, pref1), pref2)
    new-companies = insert(num-random(removed-companies.length()), pref2, 
      insert(num-random(removed-companies.length()), pref1, removed-companies))
    matchmaker(new-companies, candidates)
  end
end

fun remove-element<t>(aloa :: List<t>, value :: t) -> List<t>:
  doc:```consumes a list of any (aloa) and a value
      removes the first instance of the value from the list```
  cases (List) aloa:
    | empty => empty
    | link(f, r) =>
      if f == value:
        r
      else:
        link(f, remove-element(r, value))
      end
  end
end