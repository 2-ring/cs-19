use context essentials2021

provide: get-art-in-1, get-art-in-2, get-art-in-3 end

include my-gdrive("tables-common.arr")
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# You may write implementation-specific tests (e.g., of helper functions) in this file.
import gdrive-sheets as GS
import tables as T

#datatypes

data CountedNames:
    pair(names :: List<String>, count :: Number)
end

#functions

fun get-art-in-1(art :: Table, cc :: Table, art-id :: Number, currency :: String)
  -> Number:
  doc: ```returns the price of a given piece of artwork in the specified currency 
       assuming that each term in artwork is unique and that every pair of currencies 
       you need is listed exactly once in the expected conversion direction```
  
  relevant-info =
  select cost, currency from
  (sieve art using id: id == art-id end)
  end
  
  og-c = relevant-info.row-n(0)["currency"]
  og-value = relevant-info.row-n(0)["cost"]
  
  if og-c == currency:
    og-value
  else: 
    conv-info = 
      sieve cc using from-c, to-c: 
        ((from-c == og-c) and (to-c == currency))
      end.row-n(0)
    
    og-value * conv-info["conv-rate"]
  end
end      

fun get-art-in-2(art :: Table, cc :: Table, art-id :: Number, currency :: String)
  -> Number:
  doc: ```returns the price of a given piece of artwork in the specified currency, 
       if there are missing or duplicate entries for either the input artwork id or
       the necessary conversion factor, it should raise an exception```
  
  art-info =
  select cost, currency from
  (sieve art using id: id == art-id end)
  end
  
  l-art = art-info.length()
  ask:
    | l-art == 0 then: raise("art-id invalid: missing")
    | l-art > 1 then: raise("art-id invalid: duplicate")
    | otherwise:
  
      og-c = art-info.row-n(0)["currency"]
      og-value = art-info.row-n(0)["cost"]

      if og-c == currency:
        og-value
      else: 
        normal = sieve cc using from-c, to-c: 
        ((from-c == og-c) and (to-c == currency)) end
        l = normal.length()
       
        ask:
          | l > 1 then: raise("conversion invalid: duplicate")
          | l == 0 then: raise("conversion invalid: missing")
          | otherwise:
            conv = normal.row-n(0)
            if conv["from-c"] == og-c:
              og-value * conv["conv-rate"]
            else:
              og-value / conv["conv-rate"]
            end
        end
      end
  end
end  

fun get-art-in-3(art :: Table, cc :: Table, art-id :: Number, currency :: String) 
  -> Number:
  doc: ```returns the price of a given piece of artwork in the specified currency, 
       if there are missing or duplicate entries for either the input artwork id or
       the necessary conversion factor, it should raise an exception--but also accounting 
       for the potential for inverse conversions```
  
  art-info =
  select cost, currency from
  (sieve art using id: id == art-id end)
  end
  
  l-art = art-info.length()
  ask:
    | l-art == 0 then: raise("art-id invalid: missing")
    | l-art > 1 then: raise("art-id invalid: duplicate")
    | otherwise:
  
      og-c = art-info.row-n(0)["currency"]
      og-value = art-info.row-n(0)["cost"]

      if og-c == currency:
        og-value
      else: 
        normal = sieve cc using from-c, to-c: ((from-c == og-c) and (to-c == currency)) end
        inverse = sieve cc using from-c, to-c: ((from-c == currency) and (to-c == og-c)) end
        
        l-normal = normal.length()
        l-inverse = inverse.length()
        
        ask:
          | ((l-normal > 1) or (inverse.length() > 1)) then: raise("conversion invalid: duplicate")
          | ((l-normal == 0) and (l-inverse == 0)) then: raise("conversion invalid: missing")
          |otherwise:
                           
            if inverse == inverse.empty():
              og-value * normal.row-n(0)["conv-rate"]
            else:
              og-value / inverse.row-n(0)["conv-rate"]
            end
        end
      end
  end
end


titanic-raw-loader = 
  GS.load-spreadsheet("1ZqZWMY_p8rvv44_z7MaKJxLUI82oaOSkClwW057lr3Q")

titanic-raw = load-table:
  survived :: Number,
  pclass :: Number,
  raw-name :: String,
  sex :: String,
  age :: Number,
  sib-sp :: Number,
  par-chil :: Number,
  fare :: Number
  source: titanic-raw-loader.sheet-by-name("titanic", true)
end


fun to-count(names :: List<String>, unique :: List<String>)
  -> List<Number>:
  doc: "counts how many times each name in 'unique' appears in 'names' and adds the values to a list"
  
  cases (List) unique:
    | empty => empty
    | link(f, r) =>
      link(
        filter(lam(n): n == f end, names).length(),
        to-count(names, r))
  end
where:
  to-count([list: "1", "1", "1", "2", "3", "3"], [list: "1", "2", "3"]) is [list: 3, 1, 2]
  to-count([list: ], [list: "1", "2", "3"]) is [list: 0, 0, 0]
  to-count([list: "1"], [list: "1", "2", "3"]) is [list: 1, 0, 0]
end

fun add-unique<T>(item :: T, lst :: List<T>) 
  -> List<T>:
  doc: "adds a term to a list if it is not already a member"
  
  if member(lst, item):
    lst
  else:
    link(item, lst)
  end
where:
  add-unique(2, [list: 1]) is [list: 2, 1]
  add-unique(10, [list: 1, 5, 2, 10]) is [list: 1, 5, 2, 10]
  add-unique(3, [list: 4, 2, 99, 100]) is [list: 3, 4, 2, 99, 100]
end

  
fun get-list-max(lst :: List<Number>)
  -> Number:
  doc: "finds the maximum value of a non-empty vector"
  fold(lam(acc, n): num-max(acc, n) end, 0, lst)
where:
  get-list-max([list: 6, 6, 3, 6]) is 6
  get-list-max([list: 1]) is 1
  get-list-max([list: 8, 21, 3, 4]) is 21
  get-list-max([list: -8, 0, -3, -4]) is 0
end

fun n-largest(n :: Number, l :: List<Number>)
  -> List<Number>:
  doc: "returns a list of the largest n unique terms from a list of numbers"
  
  if n <= 0:
    empty
  else:
    max = get-list-max(l)
    link(
      max,    
      n-largest(n - 1, remove-all(max, l)))     
  end
where:
  n-largest(0, [list: 8, 10, 3, 6, 3, 11]) is empty
  n-largest(1, [list: 8, 10, 3, 6, 3, 11]) is [list: 11]
  n-largest(6, [list: 8, 10, 3, 6, 3, 11]) is [list: 11, 10, 8, 6, 3, 0]
  n-largest(1, [list: 8]) is [list: 8]
  n-largest(2, [list: 8, 10, 3, 6, 3, 11, 11]) is [list: 11, 10]
end

fun remove-all<T>(item :: T, l :: List<T>)
  -> List<T>:
  doc: "removes all instances of an item from a list"
  
  cases (List) l:
    | empty => empty
    | link(f, r) =>
      if f == item:
        remove-all(item, r)
      else:
        link(f, remove-all(item, r))
      end
  end
where:
  remove-all(6, [list: 6, 6, 3, 5, 2, 6]) is [list: 3, 5, 2]
  remove-all(3, [list: 6, 6, 3, 5, 2, 6]) is [list: 6, 6, 5, 2, 6]
  remove-all(21, [list: 6, 6, 3, 5, 2, 6]) is [list: 6, 6, 3, 5, 2, 6]
  remove-all("hello", [list: "hello"]) is [list: ] 
  remove-all("hello", [list: ]) is [list: ] 
end
  
fun make-unique(original :: List<String>)
  -> List<String>:
  doc: "eliminates all duplicate elements within a list"
  cases (List) original:
    | empty => empty
    | link(f, r) =>
      add-unique(f, make-unique(r))
  end 
where:
  make-unique([list: 6, 6, 3, 5, 2, 6]) is [list: 3, 5, 2, 6]
  make-unique([list:]) is [list:]
  make-unique([list: 1]) is [list: 1]
  make-unique([list: "how", "do", "you", "do"]) is [list: "how", "you", "do"]
end

fun popular-helper(max-counts :: List<Number>, counted-names :: List<CountedNames>)
  -> List<CountedNames>:
  doc: "finds all names associated with each value in max-counts and returns as a list"
  
  cases (List) max-counts:
      | empty => empty
      | link(f, r) =>
      
      link(
        pair(
          fold(
            lam(acc, p): 
              if f == p.count: link(p.names.get(0), acc)          
              else: acc end
            end,
            empty, counted-names),
          f),
          
       popular-helper(r, counted-names))
  end
end       
            
fun popular-names(raw-data :: Table,  target-sex :: String)
  -> List<CountedNames>:
  doc: "finds the 7 most common names of the given sex in raw-data"
  
  raw-names = extract raw-name from (sieve raw-data using sex: sex == target-sex end) end
  names = map(
    lam(n): string-split(string-split-all(n, " ").get(1), "(").last() end,
    raw-names)
  unique = make-unique(names)
  count = to-count(names, unique)
  
  max-counts = n-largest(7, count)
  
  counted-names = map2(
    lam(n, mc): pair([list: n], mc) end,
    unique,
    count)
  popular-helper(max-counts, counted-names)
end


fun title-frequencies(raw-data :: Table)
  -> List<CountedNames>:
  doc: "returns each unique title associated with it's frequency in raw data"
  
  raw-names = extract raw-name from raw-data end
  titles = map(
    lam(n): string-split(n, ".").get(0) end,
    raw-names)
  unique = make-unique(titles)
  count = to-count(titles, unique)
  
  map2(
    lam(t, mc): pair([list: t], mc) end,
    unique,
    count)
end