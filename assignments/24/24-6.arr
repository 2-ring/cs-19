use context starter2024
use context starter2024
include math
include string-dict


# Data definitions

data Operator:
  | add
  | mul
  | div
  | sub
end

data Expression:
  | num(val :: Option<Number>)
  | operation(
      operator :: Operator, 
      nums :: List<Expression>)
end

data Hand:
  | hand(
      exp :: Expression, 
      ops :: List<Operator>,
      nums :: List<Number>)
end

# Test expressions

# 3
exp1 = num(some(3))

# 2 * 3
exp2 = operation(mul, [list: num(some(2)), num(some(3))])

# 3 * (1 + 6)
exp3 = operation(mul, [list: num(some(3)), operation(add, [list: num(some(1)), num(some(6))])])

# (5 * 2) + (8 + 6)
exp4 = operation(add, [list:
    operation(mul, [list: num(some(5)), num(some(2))]), 
    operation(add, [list: num(some(8)), num(some(6))])])

# -3 * ((1 + (2 * 3)) + 8)
exp5 = operation(mul, 
  [list: num(some(-3)),
    operation(add,
      [list: 
        operation(
          add, 
          [list: num(some(1)), 
            operation(mul, [list: num(some(2)), num(some(3))])]),
        num(some(8))])])

# 8 / ((9 * 3) / (6 - (2 * 3)))
exp6 = operation(div,
  [list: num(some(8)),
    operation(div, [list:
        operation(mul, [list:
            num(some(9)),
            num(some(3))]),
        operation(sub, [list:
            num(some(6)),
            operation(mul, [list:
                num(some(2)),
                num(some(3))])])])])

# Code

fun compute-operation(
    op :: Operator, 
    nums :: List<Number>%(is-link)) -> Option<Number>:
  doc: ```Applies the operator to the given list of numbers,
       starting from the left. Returns none if the operation
       isn't possible (e.g. division by 0), otherwise returns
       some(result).```
  len = nums.length()
  cases (List) nums:
    | empty => raise("Shouldn't be here")
    | link(first, rest) =>
      cases (List) rest:
        | empty => raise("Shouldn't be here")
        | link(second, _) =>
          cases (Operator) op:
            | add => if len == 2:
                some(first + second)
              else:
                raise("add is a binary operation")
              end
            | mul => if len == 2:
                some(first * second)
              else:
                raise("mul is a binary operation")
              end
            | sub => if len == 2:
                some(first - second)
              else:
                raise("sub is a binary operation")
              end
            | div => if len == 2:
                if second == 0:
                  none
                else:
                  some(first / second)
                end
              else:
                raise("div is a binary operation")
              end
          end
      end
  end
where:
  compute-operation(add, [list: 1, 2]) is some(3)
  compute-operation(add, [list: 5, -5]) is some(0)
  compute-operation(mul, [list: 3, 1]) is some(3)
  compute-operation(mul, [list: 2, 0]) is some(0)
  compute-operation(sub, [list: 5, 8]) is some(-3)
  compute-operation(div, [list: 0, 0]) is none
  compute-operation(div, [list: 5, 0]) is none
  compute-operation(div, [list: 5, 2]) is some(5/2)
end

fun count-nums(exp :: Expression) -> Number:
  doc: "Computes how many raw numbers are in the expression."
  cases (Expression) exp:
    | num(val) => 1
    | operation(op, nums) =>
      safe-sum(nums.map(count-nums))
  end
where:
  count-nums(exp1) is 1
  count-nums(exp2) is 2
  count-nums(exp3) is 3
  count-nums(exp4) is 4
  count-nums(exp5) is 5
  count-nums(exp6) is 6
end

fun eval(exp :: Expression) -> Option<Number>:
  doc: ```Resolves an expression to a some(result), or none
       if the result cannot be evaluated (e.g. divison by 0).```
  cases (Expression) exp:
    | num(val) => val
    | operation(op, nums) =>
      evaluated-nums = nums.map(eval)
      any-failed = evaluated-nums.any(is-none)
      if (any-failed):
        none
      else:
        compute-operation(op, evaluated-nums.map(lam(n :: Option<Number>):
              cases (Option) n:
                | none => raise(```Conditional to check if any sub-expression
                                evaluations failed was false, even though 
                                there is a none in evaluated-nums```)
                | some(val) => val
              end
            end))
      end
  end
where:
  eval(exp1) is some(3)
  eval(exp2) is some(6)
  eval(exp3) is some(21)
  eval(exp4) is some(24)
  eval(exp5) is some(-45)
  eval(exp6) is none
end

fun remove-first-occurrence<T>(lst :: List<T>, elt :: T) -> List<T>:
  doc: ```Returns the list with the earliest instance of 
       elt removed.```
  cases (List<T>) lst:
    | empty =>
      empty
    | link(f,r) =>
      if f == elt:
        r
      else:
        link(f, remove-first-occurrence(r, elt))
      end
  end
where:
  remove-first-occurrence([list: 1,1,1,2,2,2,3,3], 2) 
    is [list: 1,1,1,2,2,3,3]
  remove-first-occurrence([list: 1,1,1,2,2,2,3,3], 3) 
    is [list: 1,1,1,2,2,2,3]
  remove-first-occurrence([list: 1], 3) 
    is [list: 1]
  remove-first-occurrence([list: 3], 3) 
    is empty
  remove-first-occurrence(empty, 3) 
    is empty
end

fun unique-arrangements(
    h :: Hand, 
    goal :: Number, 
    full :: (Hand -> Boolean)) -> Number:
  doc: ```Determines how many full, unique hands evaluating
       to goal can be made given the starting hand. A hand's 
       expression is considered full when full(hand) == true.```
  if full(h):
    if eval(h.exp) == some(goal): 1 else: 0 end
  else:
    fold(lam(count, curr-op):
        count + fold(lam(inner-count, curr-num):
            inner-count + unique-arrangements(hand(
                operation(
                  curr-op, [list: num(some(curr-num)), h.exp]),
                remove-first-occurrence(h.ops, curr-op), 
                remove-first-occurrence(h.nums, curr-num)),
              goal, full)
          end, 0, distinct(h.nums))
      end, 0, distinct(h.ops))
  end
where:
  unique-arrangements(
    hand(
      operation(
        mul,
        [list: 
          operation(mul, 
            [list: num(some(3)), num(some(4))]),
          num(some(1))]),
      [list: mul, add, add, add],
      [list: 1,1,1,2,2,2,2,3,3,3,4,4,4,5,5,5,5]),
    24,
    lam(h): count-nums(h.exp) == 4 end) is 1
  unique-arrangements(
    hand(
      operation(mul, [list: num(some(3)), num(some(4))]),
      [list: mul, mul, add, add, add],
      [list: 1,1,1,1,2,2,2,2,3,3,3,4,4,4,5,5,5,5]),
    24,
    lam(h): count-nums(h.exp) == 4 end) is 2
  unique-arrangements(
    hand(
      num(some(4)),
      [list: mul, mul, mul, add, add, add],
      [list: 1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,5,5,5,5]),
    5,
    lam(h): count-nums(h.exp) == 2 end) is 1
  unique-arrangements(
    hand(
      num(some(1)),
      [list: mul, mul, mul, add, add, add],
      [list: 1,1,1,2,2,2,2,3,3,3,3,4,4,4,4,5,5,5,5]),
    0,
    lam(h): count-nums(h.exp) == 4 end) is 0
end

fun how-many-24-5-2() -> Number:
  op-cards = [list: 
    mul, mul, mul, 
    add, add, add]
  num-cards = [list: 
    1,1,1,1,
    2,2,2,2,
    3,3,3,3,
    4,4,4,4,
    5,5,5,5]
  safe-sum(range(1, 6).map(lam(start-num):
        unique-arrangements(hand(
            num(some(start-num)), op-cards, 
            remove-first-occurrence(num-cards, start-num)),
          24,
          lam(h): count-nums(h.exp) == 4 end)
      end))
end

fun how-many-24-5-4() -> Number:
  op-cards = [list: 
    mul, mul, mul, 
    add, add, add, 
    sub, sub, sub, 
    div, div, div]
  num-cards = [list: 
    1,1,1,1,
    2,2,2,2,
    3,3,3,3,
    4,4,4,4,
    5,5,5,5]
  safe-sum(range(1, 6).map(lam(start-num):
        unique-arrangements(hand(
            num(some(start-num)), op-cards, 
            remove-first-occurrence(num-cards, start-num)),
          24,
          lam(h): count-nums(h.exp) == 4 end)
      end))
end

fun how-many-24-10-4() -> Number:
  op-cards = [list: 
    mul, mul, mul, 
    add, add, add, 
    sub, sub, sub, 
    div, div, div]
  num-cards = [list: 
    1,1,1,1,
    2,2,2,2,
    3,3,3,3,
    4,4,4,4,
    5,5,5,5,
    6,6,6,6,
    7,7,7,7,
    8,8,8,8,
    9,9,9,9,
    10,10,10,10]
  safe-sum(range(1, 11).map(lam(start-num):
        unique-arrangements(hand(
            num(some(start-num)), op-cards, 
            remove-first-occurrence(num-cards, start-num)),
          24,
          lam(h): count-nums(h.exp) == 4 end)
      end))
end

### 24-4 New Code ###

fun safe-sum(ns :: List<Number>) -> Number:
  doc: ```Sums all Numbers in the given List. Doesn't conflict 
       with the type checker.```
  cases(List) ns:
    | empty => 0
    | link(f, r) =>
      f + safe-sum(r)
  end
end

### 24-5 New Code ###

fun max-result<T>(func :: (T -> Number), inputs :: List<T>) -> T:
  doc: ```Finds the maximum value when the given Function is 
       called upon each term in the given List. Assumes all 'inputs' result 
       in natural Number outputs when passed to 'func'.```
  fold({(acc, curr):
      new-result = func(curr)
      if new-result > acc:
        new-result
      else:
        acc
      end}, 
    -1, inputs)
end

#adapted from unique-arrangements
fun highest-helper(
    op-cards :: List<Operator>, 
    num-cards :: List<Number>) -> Number:
  doc: ```Analyzes all possible configurations that can be generated 
       using the provided cards. Evaluates each configuration to determine 
       the resulting values and returns the frequency of the most commonly
       occurring resultant value.```
  frequencies = [mutable-string-dict:] #tracks the frequency of each result
  #helper function to perform recursive step
  fun get-highest(h :: Hand) -> Number:
    #if the provided expression represents a complete configuration
    if count-nums(h.exp) == 4:
      cases (Option) eval(h.exp) block:
          #-1 is outside otherwise generatable values because represents frequency 
        | none => -1 
        | some(value) => 
          value-str = to-string(value)
          prev-freq = 
            cases (Option) frequencies.get-now(value-str):
              | none => 0
              | some(n) => n
            end
          new-freq = prev-freq + 1
          frequencies.set-now(value-str, new-freq)
          new-freq
      end            
    else:
      max-result({(curr-op):
          max-result({(curr-num):
              new-hand = hand(
                operation( #add new operation to hand
                  curr-op, [list: num(some(curr-num)), h.exp]),
                #remove cards used from hand
                remove-first-occurrence(h.ops, curr-op), 
                remove-first-occurrence(h.nums, curr-num))
              #recursive step using new values
              get-highest(new-hand)},
            distinct(h.nums))}, #for each possible combination of num 
        distinct(h.ops)) #and op
    end
  end
  #exploring all possible initial values
  max-result({(start-num):
      get-highest(hand(
          num(some(start-num)), op-cards, 
          remove-first-occurrence(num-cards, start-num)))}, 
    range(1, 11))
end

fun highest-count() -> Number:
  doc: ```As described in problem handout.```
  op-cards = 
    #all possible operators
    [list: 
      mul, mul, mul, 
      add, add, add, 
      sub, sub, sub, 
      div, div, div]
  num-cards = 
    #all possible numbers
    [list: 
      1,1,1,1,
      2,2,2,2,
      3,3,3,3,
      4,4,4,4,
      5,5,5,5,
      6,6,6,6,
      7,7,7,7,
      8,8,8,8,
      9,9,9,9,
      10,10,10,10]
  highest-helper(op-cards, num-cards)
end

### 24-6 New Code ###

fun next-operation(prev-vals :: List<Number>) -> List<Number>:
  doc: ```For each Number in the given List, the function calculates 
       the value of every possible single-operator expression including 
       it. Returns a List of all values found.```
  block:
    #using mutable data for speed
    var next-vals = empty
    #all possible "cards"
    poss-ops = [list: mul, add, sub, div]
    poss-nums = range(1, 11)
    #calculating every obtainable value
    for each(curr-op from poss-ops):
      for each(curr-num from poss-nums):
        for each(prev-exists from prev-vals):
          cases (Option) prev-exists:
            | none => none
            | some(prev-val) =>
              result = compute-operation(curr-op, [list: curr-num, prev-val])
              new-val = 
                cases (Option) result:
                  | none => none
                  | some(val) => some(val)
                end
              next-vals := link(new-val, next-vals)
          end
        end
      end
    end
    #all values found
    next-vals
  end
end

fun final-operation(prev-vals :: List<Number>) -> Number:
  doc: ```For each Number in the given List, the function calculates 
       the value of every possible single-operator expression including 
       it. It keeps a running total of both the frequency of each value 
       and the current highest frequency. Returns the highest frequency 
       once all possible values have been explored.```
  block:
    #using mutable data for speed
    var highest-freq = -1
    frequencies = [mutable-string-dict:]
    #all possible "cards"
    poss-ops = [list: mul, add, sub, div]
    poss-nums = range(1, 11)
    #exploring every possible expression
    for each(curr-op from poss-ops):
      for each(curr-num from poss-nums):
        for each(prev-exists from prev-vals):
          cases (Option) prev-exists:
            | none => none
            | some(prev-val) =>
              result = compute-operation(curr-op, [list: curr-num, prev-val])
              highest-freq := cases (Option) result block:
                | none => highest-freq
                | some(val) => 
                  val-str = to-string(val)
                  prev-freq = 
                    cases (Option) frequencies.get-now(val-str):
                      | none => 0
                      | some(n) => n
                    end
                  new-freq = prev-freq + 1
                  frequencies.set-now(val-str, new-freq)
                  if new-freq > highest-freq:
                    new-freq
                  else:
                    highest-freq
                  end
              end
          end
        end
      end
    end
    #returns value after exploring all possibilities
    highest-freq
  end
end

fun highest-count-fast() -> Number:
  doc: ```As described in the problem handout.```
  initial-values = range(1, 11).map(some) #dynamic base case
  num-ops = 3
  all-values = 
    for fold(prev-values from initial-values, _ from range(1, num-ops)):
      next-operation(prev-values)
    end
  final-operation(all-values)
end

highest-count-fast()
