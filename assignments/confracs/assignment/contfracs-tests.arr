use context shared-gdrive("contfracs-context.arr", "1mr5nHB7DDdOffE_hiovBiEuuBsl_59Gh")
include shared-gdrive("contfracs-definitions.arr", "1fFz3TaWdZgIfNxSGVYx0UQz_GXOBIVsc")

include my-gdrive("contfracs-common.arr")
import take, repeating-stream, threshold, fraction-stream, terminating-stream, repeating-stream-opt, threshold-opt, fraction-stream-opt, cf-phi, cf-phi-opt, cf-e, cf-e-opt, cf-pi-opt
from my-gdrive("contfracs-code.arr")
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# Write your examples and tests in here. These should not be tests of implementation-specific details (e.g., helper functions).

## Part 2: Options and Terminating Streams

repeat-3 = repeating-stream([list: 1, 2, 3])
repeat-4 = repeating-stream([list: 21, 3, 18, 6])

#take

check "take: standard functionality":
  take(ones, 3) is [list: 1, 1, 1]
  take(repeat-3, 5) is [list: 1, 2, 3, 1, 2]
end

check "take: other data types":
  take(strings, 1) is [list: "string"]
  take(emptys, 2) is [list: empty, empty]
  take(nones, 3) is [list: none, none, none]
end

check "take: n is 0":
  take(ones, 0) is [list: ]
  take(emptys, 0) is [list: ]
end

#repeating-stream

check "repeating-stream: standard functionality":
  take(repeat-3, 8)
    is [list: 1, 2, 3, 1, 2, 3, 1, 2]
  take(repeating-stream([list: 2, 3]), 3)
    is [list: 2, 3, 2]
  take(repeat-3, 0) is [list: ]
  take(repeat-4, 6) is [list: 21, 3, 18, 6, 21, 3]
end

check "repeating-stream: one term":
  take(repeating-stream([list: 1]), 3) is [list: 1, 1, 1]
  take(repeating-stream([list: 1]), 30) is take(ones, 30)
end

#cf-phi

check "cf-phi: standard functionality":
  take(cf-phi, 30) is take(ones, 30)
  take(cf-phi, 3) is [list: 1, 1, 1]
  take(cf-phi, 10).get(8) is 1
end

#cf-e

check "cf-e: standard functionality":
  take(cf-e, 12) is [list: 2,1,2,1,1,4,1,1,6,1,1,8] 
  take(cf-e, 4) is [list: 2,1,2,1] 
  take(cf-e, 12).get(8) is 6
end

#fraction-stream

check "fraction-stream: standard functionality":
  take(fraction-stream(cf-e), 3) is [list: 2, 3, 8/3]
  take(fraction-stream(repeat-4), 4) 
    is [list: 21, 64/3, 1173/55, 7102/333]
  take(fraction-stream(ones), 10)
    is [list: 1, 2, 3/2, 5/3, 8/5, 13/8, 21/13, 34/21, 55/34, 89/55]
end

#threshold

check "threshold: standard functionality":
  threshold(fraction-stream(repeat-4), 1/100) is 64/3
  threshold(repeating-stream([list: 1, 2, 2.5, 2.75, 2.7]), 1/18) is 2.75 
end

check "threshold: thresh equal to diff":
  threshold(fraction-stream(ones), 1/6) is 5/3
  threshold(fraction-stream(ones), 1) is 2
end

## Part 2: Options and Terminating Streams

repeat-3-opt = repeating-stream-opt([list: 1, 2, 3])
repeat-4-opt = repeating-stream-opt([list: 21, 3, 18, 6])
terminating-3 = terminating-stream([list: 1, 2, 3])
terminating-5 = terminating-stream([list: 10, 2, 5, 18, 1])

#terminating-stream

check "terminating-stream: within somes":
  take(terminating-3, 3) is [list: some(1), some(2), some(3)]
  take(terminating-stream([list: 21, 3, 19]), 2) is [list: some(21), some(3)]
end

check "terminating-stream: past end":
  take(terminating-3, 5) is [list: some(1), some(2), some(3), none, none]  
  take(terminating-stream([list: 1]), 5) is [list: some(1), none, none, none, none]  
  take(terminating-stream(take(ones, 8)), 9) 
    is [list: some(1), some(1), some(1), some(1), some(1), some(1), some(1), some(1), none]
end

check "terminating-stream: empty input":
  take(terminating-stream(empty), 1) is [list: none]
  take(terminating-stream(empty), 3) is [list: none, none, none]
end

#repeating-stream-opt

check "repeating-stream-opt: standard functionality":
  take(repeat-3-opt, 7)
    is [list: some(1), some(2), some(3), some(1), some(2), some(3), some(1)]
  take(repeating-stream-opt([list: 2, 3]), 3)
    is [list: some(2), some(3), some(2)]
  take(repeat-4-opt, 6) 
    is [list: some(21), some(3), some(18), some(6), some(21), some(3)]
end

check "repeating-stream-opt: one term":
  take(repeating-stream-opt([list: 1]), 3) is [list: some(1), some(1), some(1)]
  take(repeating-stream-opt([list: 1]), 30) is take(ones-opt, 30)
end

#fraction-stream-opt

check "fraction-stream-opt: infinite sequences":
  take(fraction-stream-opt(repeat-4-opt), 4)
    is [list: some(21), some(64/3), some(1173/55), some(7102/333)]
  take(fraction-stream-opt(ones-opt), 10).get(9) is some(89/55)
end

check "fraction-stream-opt: finite sequences":
  take(fraction-stream-opt(terminating-3), 4) 
    is [list: some(1), some(3/2), some(10/7), none]
  take(fraction-stream-opt(terminating-5), 3) 
    is [list: some(10), some(21/2), some(115/11)]
  take(fraction-stream-opt(terminating-5), 10).get(9) is none
end

check "fraction-stream-opt: empty stream":
  take(fraction-stream-opt(nones), 5) is [list: none, none, none, none, none]
end

#threshold-opt

check "threshold-opt: infinite sequences":
  threshold-opt(fraction-stream-opt(repeat-4-opt), 10) is 21
  threshold-opt(fraction-stream-opt(ones-opt), 1/100) is  13/8
end

check "threshold-opt: finite sequences":
  threshold-opt(fraction-stream-opt(terminating-5), 1/2) is 10.5
  threshold-opt(terminating-5, 3.1) is 2
end

check "threshold-opt: threshold too small":
  threshold-opt(terminating-3, 1/10) raises "Threshold too small"
  threshold-opt(nones, 10) raises "Threshold too small"
end

check "threshold: thresh equal to diff":
  threshold-opt(fraction-stream-opt(ones-opt), 1/6) is 5/3
  threshold-opt(fraction-stream-opt(ones-opt), 1) is 2
end

#cf-phi-opt

check "cf-phi-opt: standard functionality":
  take(cf-phi-opt, 30) is take(ones-opt, 30)
  take(cf-phi-opt, 3) is [list: some(1), some(1), some(1)]
  take(cf-phi-opt, 10).get(8) is some(1)
end

#cf-e

check "cf-e-opt: standard functionality":
  take(cf-e-opt, 7) 
    is [list: some(2), some(1), some(2), some(1), some(1), some(4), some(1)] 
  take(cf-e-opt, 4) is [list: some(2), some(1), some(2), some(1)]
  take(cf-e-opt, 12).get(8) is some(6)
end

#cf-pi-opt

check "cf-pi-opt: standard functionality":
  take(fraction-stream-opt(cf-pi-opt), 5) 
    is [list: some(3), some(22/7), some(333/106), some(355/113), some(103993/33102)]
  take(cf-pi-opt, 5) 
    is [list: some(3), some(7), some(15), some(1), some(292)]
  take(cf-pi-opt, 12).get(3) is some(1)
end
