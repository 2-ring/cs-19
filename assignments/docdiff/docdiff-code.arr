use context essentials2021

provide: overlap end

include my-gdrive("docdiff-common.arr")
import gdrive-js("docdiff_qtm-validation.js", "11H5gJQtW9TJaiFkWw51fR4_oIibmLr7X") as Validation
provide from Validation: overlap-in-ok, overlap-out-ok end
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# You may write implementation-specific tests (e.g., of helper functions) in this file.

fun add-unique<T>(doc1 :: List<T>, doc2 :: List<T>) 
  -> List<T>:
  doc: "appends two lists of unique elements to form another unique list"
  
  cases (List) doc2:
    | empty => doc1
    | link(f, r) => 
      if member(doc1, f):
        add-unique(doc1, r)
      else:
        add-unique(link(f, doc1), r)
      end
  end
where:
  add-unique([list: "1", "3", "4"], [list: "1", "2", "99"]) is [list: "99", "2", "1", "3", "4"]
end
  
fun to-vector(doc1 :: List<String>, unique-words :: List<String>)
  -> List<Number>:
  doc: "counts how many times each word appears in 'unique-words' and adds them to a vector"
  
  cases (List) unique-words:
    | empty => empty
    | link(f, r) =>
      link(
        filter(lam(w): w == f end, doc1).length(),
        to-vector(doc1, r))
  end
where:
  to-vector([list: "5", "3", "1"], [list: "2", "5", "3", "1", "8"]) is [list: 0, 1, 1, 1, 0]
  to-vector([list: "5", "5", "2", "5"], [list: "5", "3", "2"]) is [list: 3, 0, 1]
end

fun list-to-lower(lst :: List<String>)
  -> List<String>:
  doc: "ensures all strings in a list contain on lower case charecters"
  
  cases (List) lst:
    | empty => empty
    | link(f, r) =>
      link(string-to-lower(f), list-to-lower(r))
  end
where:
  list-to-lower([list: "ABC"]) is [list: "abc"]
  list-to-lower([list: "HelO", "Im", "WiGgilY"]) is [list: "helo", "im", "wiggily"]
  list-to-lower([list: "].'", "@}{["]) is [list: "].'", "@}{["]
  list-to-lower([list: ]) is [list: ]
end
  
#vectors must be same length
fun dot-product(v1 :: List<Number>, v2 :: List<Number>)
  -> Number:
  doc: "calculates the dot product of two vectors"
  
  cases (List) v1:
    | empty => 0
    | link(f, r) =>
      (f * v2.get(0)) + dot-product(r, v2.drop(1))
  end
where:
  dot-product([list: 5, 3, 2], [list: 0, 1, 3]) is 9
  dot-product([list: 1, 2, 3], [list: 4, 5, 6]) is 32
  dot-product([list: -2, 4, 5], [list: 3, -1, 2]) is 0
end

fun overlap(doc1-upper :: List<String>, doc2-upper :: List<String>) 
  -> Number:
  doc: "computes the overlap of two non-empty documents"
  
  doc1 = list-to-lower(doc1-upper)
  doc2 = list-to-lower(doc2-upper)
  
  unique-words = add-unique(doc1, doc2)
  v1 = to-vector(doc1, unique-words)
  v2 = to-vector(doc2, unique-words)
  
  dot-product(v1, v2) / num-max(
    dot-product(v1, v1),
    dot-product(v2, v2))
end




l1 = [list: "a", "b", "c"]
l2 = [list: "d", "d", "d", "b"]
l3 = [list: "seNteNcE", "test", "woRds", "test", "words", "tEst", "FRANCE"]
l4 = [list: "SENTENCE", "seNtence", "test", "test", "words", "document"]
l5 = [list: "", "sentence"]
l6 = [list: "1.,", "0-25", "?t3s T", "?T3S T"]
l7 = [list: "5", "1.,", "1.,", "?t3S t", "0-25", "45"]
l8 = [list: "ethan", "ethan", "ethan", "ethan"]
l9 = [list: "ethan", "ethan"]
l10 = [list: "ABC,./';[]{}`|*&amp;^%$#@!()ajkl", "ABC,./';[]{}`|*&amp;^%$#@!()aJkl", "", ""]
l11 = [list: "AbC,./';[]{}`|*&amp;^%$#@!()ajKl", ""]
l12 = [list: " "]
l13 = [list: "7"]
l14 = [list: "3", "3", "3", "6", "6", "3", "5", "5", "3", "7", "7", "8"]
l15 = [list: "3", "3", "3", "3", "6", "6", "6", "3", "5", "5", "3", "7", "7", "7"]
l16 = [list: "  ", "   ", "  ", " ", "     ", "   ", "  ", "  "]
l17 = [list: "   ", " ", "   ", " ", "  ", "    ", "  ", "  "]

check "Quatermaster Overlap": 
  {l1;l2} satisfies overlap-in-ok
  {l1;l1} satisfies overlap-in-ok
  {l1;l3} satisfies overlap-in-ok
  {l4;l5} satisfies overlap-in-ok
  {l6;l7} satisfies overlap-in-ok
end

check "Overlap: given example":
  overlap(l1, l2) is 0.1
end
check "Overlap: same document":
  overlap(l1, l1) is 1
end
check "Overlap: no overlap":
  overlap(l1, l3) is 0
end
check "Overlap: ignoring capitals":
  overlap(l4, l3) is 2/3
end
check "Overlap: empty strings":
  overlap(l4, l5) is 0.2
end
check "Overlap: Numbers with capitals and spaces":
  overlap(l6, l7) is 0.625
end
check "Overlap: all the same word":
  overlap(l8, l9) is 0.5
end
check "Overlap: strange characters":
  overlap(l10,l11) is 0.5
end
check "Overlap: same single word":
  overlap(l12,l12) is 1
end
check "Overlap: one word, no overlap":
  overlap(l12,l13) is 0
end
check "Overlap: all single numbers":
  overlap(l14, l15) is 23/29
end
check "Overlap: spaces":
  overlap(l16,l17) is 9/11
end
