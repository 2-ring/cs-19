use context essentials2021
include shared-gdrive("oracle-definitions.arr", "1VIj7v7L2Qy8FSRO7dh2uZki_a1NDTFxh")

include my-gdrive("oracle-common.arr")
import is-valid, oracle
	from my-gdrive("oracle-code.arr")
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# Write your examples and tests in here. These should not be tests of
# implementation-specific details (e.g., helper functions).
import sets as sets
import pick as pick


check "is-valid: empty":
	is-valid(empty, empty, sets.empty-list-set) is true
	is-valid(empty, empty, [sets.set: hire(0, 0)]) is false
end

check "is-valid: length-1":
	is-valid([list: nl-0], [list: nl-0], [sets.set: hire(0, 0)]) is true
	is-valid([list: nl-0], [list: nl-0], [sets.set: hire(1, 1)]) is false
end

check "is-valid: all same":
	is-valid([list: nl-0-1, nl-0-1], [list: nl-0-1, nl-0-1], 
		[sets.list-set: hire(1, 1), hire(0, 0)]) is true
	is-valid([list: nl-0-1, nl-0-1], [list: nl-0-1, nl-0-1], 
		[sets.list-set: hire(0, 1), hire(1, 0)]) is false
	is-valid([list: nl-1-0, nl-1-0], [list: nl-1-0, nl-1-0], 
		[sets.list-set: hire(1, 1), hire(0, 0)]) is true
	is-valid([list: nl-1-0, nl-1-0], [list: nl-1-0, nl-1-0], 
		[sets.list-set: hire(0, 1), hire(1, 0)]) is false
	is-valid([list: nl-0-1-2, nl-0-1-2, nl-0-1-2], [list: nl-0-1-2, nl-0-1-2, nl-0-1-2], 
		[sets.list-set:hire(2, 2), hire(1, 1), hire(0,0)]) is true
	is-valid([list: nl-0-1-2, nl-0-1-2, nl-0-1-2], [list: nl-0-1-2, nl-0-1-2, nl-0-1-2], 
		[sets.list-set:hire(2, 1), hire(1, 0), hire(0,2)]) is false
end

check "is-valid: basic":
	is-valid([list: nl-1-0, nl-0-1], [list: nl-1-0, nl-1-0], 
		[sets.list-set: hire(1, 0), hire(0, 1)]) is true
	is-valid([list: nl-1-0, nl-0-1], [list: nl-1-0, nl-1-0], 
		[sets.list-set: hire(1, 1), hire(0, 0)]) is false
	is-valid([list: nl-0-1, nl-1-0], [list: nl-1-0, nl-0-1], 
		[sets.list-set: hire(1, 1), hire(0, 0)]) is true
	is-valid([list: nl-0-1, nl-1-0], [list: nl-1-0, nl-0-1], 
		[sets.list-set: hire(0, 1), hire(1, 0)]) is true
	is-valid([list: nl-1-0, nl-1-0], [list: nl-0-1, nl-0-1], 
		[sets.list-set: hire(1, 0), hire(0, 1)]) is true
	is-valid([list: nl-1-0, nl-1-0], [list: nl-0-1, nl-0-1], 
		[sets.list-set: hire(0, 0), hire(0, 1)]) is false
end

check "oracle: correct matchmaker":
	oracle(matchmaker) is true
end

check "oracle: swap inputs":
	oracle(swap-inputs) is false
end

check "oracle: random matches":
	oracle(random-matches) is false
end

check "oracle: add random":
	oracle(add-random) is false
end

check "oracle: remove random":
	oracle(remove-random) is false
end

check "oracle: modify a match":
  oracle(modify-a-match) is false
end

check "oracle: swap within match":
  oracle(swap-within-match) is false
end

check "oracle: shuffle candidates":
  oracle(shuffle-candidates) is false
end

check "oracle: shuffle companies":
  oracle(shuffle-companies) is false
end

check "oracle: swap two matches":
  oracle(swap-two-matches) is false
end

check "oracle: swap two companies":
  oracle(swap-two-companies) is false
end




