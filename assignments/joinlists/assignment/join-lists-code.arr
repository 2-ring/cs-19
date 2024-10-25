use context essentials2021
include shared-gdrive("join-lists-definitions.arr", "1gNl8Rt88uWqpbv0Hx9Fkh6ajnNoDr164")

provide:
  j-first, j-rest, j-length, j-nth, j-max, j-map, j-filter, j-reduce, j-sort,
end

include my-gdrive("join-lists-common.arr")
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# You may write implementation-specific tests (e.g., of helper functions) in
# this file.

#|
   data JoinList<T>:
  | empty-join-list
  | one(elt :: T)
  | many(mjl :: ManyJoinList<T>)
   end
|#

fun j-first<A>(jl :: JoinList<A>%(is-non-empty-jl)) -> A:
  doc: "Returns the first term in non-empty JoinList 'jl'."
  cases (JoinList) jl:
    | empty-join-list => raise("You shouldn't be here.")
    | one(elt) => elt
    | many(mjl) => mjl.rebalance-and-split({(left, right):
          j-first(left)})
  end
end

fun j-rest<A>(jl :: JoinList<A>%(is-non-empty-jl)) -> JoinList<A>:
  doc: "Returns all but the first term in non-empty JoinList 'jl'."
  cases (JoinList) jl:
    | empty-join-list => raise("You shouldn't be here.")
    | one(elt) => empty-join-list
    | many(mjl) => mjl.rebalance-and-split({(left, right):
          j-rest(left).join(right)})
  end
end

fun j-length<A>(jl :: JoinList<A>) -> Number:
  doc: "Returns the number of elements in the given JoinList."
  cases (JoinList) jl:
    | empty-join-list => 0
    | one(elt) => 1
    | many(mjl) => mjl.rebalance-and-split({(left, right):
          j-length(left) + j-length(right)})
  end
end

fun j-nth<A>(jl :: JoinList<A>%(is-non-empty-jl), n :: Number) -> A:
  doc: ```Returns the element asssociated with index 'n' in
       JoinList 'jl'---where 'jl' contains at least n + 1 elements```
  if n >= j-length(jl): raise("Index not contained within list.")
  else: cases (JoinList) jl:
      | empty-join-list => raise("You shouldn't be here.")
      | one(elt) => elt
      | many(mjl) => mjl.rebalance-and-split({(left, right):
            left-length = j-length(left)
            if n < left-length:
              j-nth(left, n)
            else:
              j-nth(right, (n - left-length))
            end})
    end
  end
end

fun j-max<A>(jl :: JoinList<A>%(is-non-empty-jl), cmp :: (A, A -> Boolean)) -> A:
  doc: ```Returns the element in non-empty JoinList 'jl' with greatest value according 
       to the comparison function 'cmp'```
  cases (JoinList) jl:
    | empty-join-list => raise("You shouldn't be here.")
    | one(elt) => elt
    | many(mjl) => mjl.rebalance-and-split({(left, right):
          left-max = j-max(left, cmp)
          right-max = j-max(right, cmp)
          if cmp(left-max, right-max): 
            left-max
          else: 
            right-max 
          end})
  end
end

fun j-map<A,B>(map-fun :: (A -> B), jl :: JoinList<A>) -> JoinList<B>:
  doc: ```Calls function 'map-fun' on all elements in JoinList 'jl' and 
       returns the result```
  cases (JoinList) jl:
    | empty-join-list => empty-join-list
    | one(elt) => [join-list: map-fun(elt)]
    | many(mjl) => mjl.rebalance-and-split({(left, right):
          j-map(map-fun, left).join(j-map(map-fun, right))})
  end
end

fun j-filter<A>(filter-fun :: (A -> Boolean), jl :: JoinList<A>) -> JoinList<A>:
  doc: ```Returns a JoinList of all elements in JoinList 'jl' that return 'true' 
       when passed to the function 'filter-fun'```
  cases (JoinList) jl:
    | empty-join-list => empty-join-list
    | one(elt) => 
      if filter-fun(elt): 
        [join-list: elt] 
      else: 
      empty-join-list 
      end
    | many(mjl) => mjl.rebalance-and-split({(left, right):
          j-filter(filter-fun, left).join(j-filter(filter-fun, right))})
  end
end

fun j-reduce<A>(reduce-func :: (A, A -> A), jl :: JoinList<A>%(is-non-empty-jl)) -> A:
  doc: ```For each term in the FunctionList 'jl' sequentially applies function 
       'reduce-func', passing in the result of each previous operation along with 
       the current element, evaluates from left to right. The reduce-func must have 
       have the associative property.```
  cases (JoinList) jl:
    | empty-join-list => raise("You shouldn't be here.")
    | one(elt) => elt
    | many(mjl) => mjl.rebalance-and-split({(left, right):
          reduce-func(j-reduce(reduce-func, left), j-reduce(reduce-func, right))})
  end
end

fun j-sort<A>(cmp-fun :: (A, A -> Boolean), jl :: JoinList<A>) -> JoinList<A>:
  doc: ```Sorts non-empty JoinList 'jl' such that the leftmost term is the 'greatest' 
       according to function 'cmp-fun'.```

  fun merge(list-a :: JoinList<A>, list-b :: JoinList<A>) -> JoinList<A>:
    doc: "Combines two sorted lists into another sorted list." 
    if is-empty-join-list(list-a):
      list-b
    else:
      if is-empty-join-list(list-b):
        list-a
      else:
        first-a = j-first(list-a) 
        first-b = j-first(list-b)
        a-goes-first = cmp-fun(first-a, first-b)
        if a-goes-first:
          [join-list: first-a].join(merge(j-rest(list-a), list-b))
        else:    
          [join-list: first-b].join(merge(list-a, j-rest(list-b)))
        end
      end
    end
  end

  fun split(sub-jl :: JoinList<A>):
    doc: "Splits jl down to elements then reassembles with merge."
    cases (JoinList) sub-jl:
      | empty-join-list => raise("You shouldn't be here.")
      | one(elt) => [join-list: elt]
      | many(mjl) => mjl.rebalance-and-split({(left, right):
            merge(split(left), split(right))})   
    end
  end
  
  split(jl)
end
