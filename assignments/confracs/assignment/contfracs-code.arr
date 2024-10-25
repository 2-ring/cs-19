use context shared-gdrive("contfracs-context.arr", "1mr5nHB7DDdOffE_hiovBiEuuBsl_59Gh")
include shared-gdrive("contfracs-definitions.arr", "1fFz3TaWdZgIfNxSGVYx0UQz_GXOBIVsc")

provide:
  take, repeating-stream, threshold, fraction-stream, terminating-stream,
  repeating-stream-opt, threshold-opt, fraction-stream-opt, cf-phi, cf-phi-opt,
  cf-e, cf-e-opt, cf-pi-opt,
end

include my-gdrive("contfracs-common.arr")
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# You may write implementation-specific tests (e.g., of helper functions) in this file.

#|
   
data Stream<T>:
 | lz-link(first :: T, rest :: (-> Stream<T>))
end
   
|#

## Part 1: Streams

fun take<T>(s :: Stream<T>, n :: Number) -> List<T>:
  doc: ```Extracts a finite prefix from Stream 's' of 
       the specified size 'n', as a list.```
  ask:
    | n < 0 then: raise("Parameter 'n' must have a positive value.")
    | n == 0 then: empty
    | n == 1 then: [list: lz-first(s)]
    | n > 1 then: link(lz-first(s), take(lz-rest(s), n - 1))
  end
end

fun repeating-stream(numbers :: List<Number>) -> Stream<Number>:
  doc: ```Returns a Stream that infinitely loops through list 'numbers'.```  
  len = numbers.length()

  fun tail(index :: Number) -> Stream<Number>:
    next-index = num-modulo(index + 1, len)
    lz-link(numbers.get(index),
      {(): tail(next-index)})
  end

  tail(0)
end

#fraction-stream helper functions

fun calculate-approx(coefficients :: List<Number>) -> Number:
  doc: ```Calculates a continued fraction approximation using the
       non-empty list of numbers 'coefficients'.```
  cases (List) coefficients:
    | empty => raise("Parameter 'coefficients' can't be empty.")
    | link(f, r) =>
      cases (List) r:
        | empty => f
        | link(_, _) => 
          f + (1 / calculate-approx(r))
      end
  end
where:
  calculate-approx([list: 2,1,2]) is 8/3
  calculate-approx([list: 4,2,6,7]) is (415/93)
  calculate-approx([list: 21]) is 21
  calculate-approx([list: 1,1,1,1,1,1,1,1]) is 34/21
  calculate-approx([list: ]) raises "empty"
end

fun fraction-stream-helper(
    prev-cs :: List<Number>, 
    all-cs :: Stream<Number>) -> Stream<Number>:
  doc: ```Recurs through the Stream of numbers 'all-cs' term-by-term, 
       creating a Stream of corresponding continued fraction approximations.```
  next-c = lz-first(all-cs)
  new-cs = prev-cs + [list: next-c]
  approx = calculate-approx(new-cs)
  lz-link(approx,
    {(): fraction-stream-helper(
        new-cs, 
        lz-rest(all-cs))})
end

fun fraction-stream(coefficients :: Stream<Number>) -> Stream<Number>:
  doc: "A wrapper function for fraction-stream-helper."
  fraction-stream-helper(empty, coefficients)
end

fun threshold(approximations :: Stream<Number>, thresh :: Number) -> Number:
  doc: ```Returns the first term in 'approximations' (a Stream of numbers) 
       where the absolute difference between it and the next term is 
       strictly below value 'thresh'.```
  f = lz-first(approximations)
  r = lz-rest(approximations)
  diff = num-abs(f - (lz-first(r)))
  if diff < thresh:
    f
  else:
    threshold(r, thresh)
  end
end

#stream defenitions

rec cf-phi :: Stream<Number> = lz-link(1, {(): cf-phi})

fun cf-e-tail(value :: Number) -> Stream<Number>:
  doc: ```Returns a Stream with the infinitely repeating 
       pattern [1, 'value', 1] where 'value' is a number that 
       is incremented by two each time the function recurs```
  lz-link(1, 
    {(): lz-link(value, 
        {(): lz-link(1,
            {(): cf-e-tail(value + 2)})})})
end
rec cf-e :: Stream<Number> = lz-link(2, {(): cf-e-tail(2)})

## Part 2: Options and Terminating Streams

fun terminating-stream(numbers :: List<Number>) -> Stream<Option<Number>>:
  doc: ```Creates a Stream starting with the terms in list 'numbers', 
       stored as 'somes'. Once the terms run out the Stream becomes 
       all 'nones'.```
  cases (List) numbers:
    | empty => nones
    | link(f, r) =>
      lz-link(some(f), {(): terminating-stream(r)})
  end
end

fun repeating-stream-opt(numbers :: List<Number>) -> Stream<Option<Number>>:
  doc: ```Returns a Stream that infinitely loops through list 'numbers', 
       storing each term as a 'some' of the Option type```  
  len = numbers.length()

  fun tail(index :: Number) -> Stream<Option<Number>>:
    next-index = num-modulo(index + 1, len)
    lz-link(some(numbers.get(index)),
      {(): tail(next-index)})
  end

  tail(0)
end

fun fraction-stream-opt-helper(
    prev-cs :: List<Option<Number>>, 
    all-cs :: Stream<Option<Number>>) -> Stream<Option<Number>>:
  doc: ```Recurs through the Stream of numbers 'all-cs' term-by-term, 
       creating a Stream of corrospodning continued fraction approximations, 
       stored as a 'some'. If 'all-cs' runs out of numbers the function 
       returns a Stream of 'nones' from then on.```
  curr-c-opt = lz-first(all-cs) #current coefficient as an option type
  cases (Option) curr-c-opt:
    | none => nones
    | some(curr-c) =>
      new-cs = prev-cs + [list: curr-c] #all coefficients so far
      approx = calculate-approx(new-cs)
      lz-link(some(approx),
        {(): fraction-stream-opt-helper(new-cs, lz-rest(all-cs))})
  end
end

fun fraction-stream-opt(coefficients :: Stream<Option<Number>>) -> Stream<Option<Number>>:
  doc: "A wrapper function for fraction-stream-opt-helper."
  fraction-stream-opt-helper(empty, coefficients)
end

fun threshold-opt(
    approximations :: Stream<Option<Number>>, 
    thresh :: Number) -> Number:
  doc: ```Returns the first term in 'approximations' (a Stream of Options) 
       where the absolute difference between it and the next term is strictly 
       below value 'thresh'. If the Stream runs out of 'some' terms before 
       this condition is met, it raises an error```
  first-opt = lz-first(approximations)
  cases (Option) first-opt:
    | none => raise("Threshold too small to approximate")
    | some(first) => 
      rest = lz-rest(approximations)
      second-opt = lz-first(rest)
      cases (Option) second-opt:
        | none => raise("Threshold too small to approximate")
        | some(second) =>
          diff = num-abs(first - second)
          if diff < thresh:
            first
          else:
            threshold-opt(rest, thresh)
          end
      end
  end
end

#stream defenitions

rec cf-phi-opt :: Stream<Option<Number>> = lz-link(some(1), {(): cf-phi-opt})

fun cf-e-opt-tail(value :: Number) -> Stream<Option<Number>>:
  doc: ```Returns a Stream with the infinitely repeating pattern 
       [some(1), some('value'), some(1)] where 'value' is a number 
       that is incremented by two each time the function recurs```
  lz-link(some(1), 
    {(): lz-link(some(value), 
        {(): lz-link(some(1),
            {(): cf-e-opt-tail(value + 2)})})})
end
rec cf-e-opt :: Stream<Option<Number>> = lz-link(some(2), {(): cf-e-opt-tail(2)})

cf-pi-opt :: Stream<Option<Number>> = 
  terminating-stream([list: 3, 7, 15, 1, 292, 1, 1, 1, 2, 1, 3, 1])

