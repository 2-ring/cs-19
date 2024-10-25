use context essentials2021
include shared-gdrive("nile-definitions.arr", "1G0l8Il4LBoenLdJ6tfu4grP4vGouMN6M")
include shared-gdrive("nile-validation.arr", "1bndIyRPJsjn95JLjKpr9wviZdGU7jdzb")

provide:
  recommend, recommend-in-ok, recommend-out-ok,
  popular-pairs, popular-pairs-in-ok, popular-pairs-out-ok
end

include my-gdrive("nile-common.arr")
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# You may write implementation-specific tests (e.g., of helper functions) in this file.


#|data defenitions
data File:
    | file(name :: String, content :: List<String>)
end

data Recommendation<A>:
    | recommendation(count :: Number, content :: List<A>)
end

data BookPair:
    | pair(book1 :: String, book2 :: string)
end|#



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

fun content-to-pairs(content :: List<String>)
  -> List<BookPair>:
  doc: "breaks the contents of a file down into all possible pairs"
  
  cases (List) content:
    | empty => empty
    | link(f, r) =>
      append(
        map(lam(title): pair(f, title) end, r),
        content-to-pairs(r))      
  end
where:
  content-to-pairs([list: "Crime", "Heaps", "Bible"]) is
  [list: pair("Crime", "Heaps"), pair("Crime", "Bible"), pair("Heaps", "Bible")]
end


fun get-all-pairs(book-records :: List<File>)
  -> List<BookPair>:
  doc: "finds all BookPairs contained within all Files in book-records"
  
  cases (List) book-records:
    | empty => empty
    | link(f, r) =>
      cases (File) f:
        | file(_, content) =>  
          my-append(content-to-pairs(content), get-all-pairs(r))
      end
  end
where:
  get-all-pairs([list:
      file("1.txt", [list: "Them", "You", "Me"]),
      file("2.txt", [list: "&&&", "Science", "Rocks", "Like 123"])]) 
  
  is
  
  [list: pair("Them", "You"), pair("Them", "Me"), pair("You", "Me"), pair("&&&", "Science"),
    pair("&&&", "Rocks"), pair("&&&", "Like 123"), pair("Science", "Rocks"), 
    pair("Science", "Like 123"), pair("Rocks", "Like 123")]
end


fun pair-contains-title(p :: BookPair, book :: String)
  -> Boolean:
  doc: "deterines whether a book is contained within a pair by checking each element against title"
  cases (BookPair) p:
    | pair(b1, b2) =>
      if (b1 == book) or (b2 == book):
        true
      else:
        false
      end
  end
where:
  pair-contains-title(pair("T_2", "T_3"), "T_1") is false
  pair-contains-title(pair("T_1", "T_2"), "T_2") is true
end

fun count<T>(lst :: List<T>, item :: T, predicate :: (T -> Boolean)) 
  -> Number:
  doc: "counts how many times items in a list match the predicate."
  
  cases (List) lst:
    | empty => 0
    | link(f, r) =>
      if predicate(f, item):
        1 + count(r, item, predicate)
      else:
        count(r, item, predicate)
      end
  end
where:
  count([list: pair("T_1", "T_2"), pair("T_4", "T_2"), pair("T_3", "T_1")], "T_1", pair-contains-title) is 2
end

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

fun my-remove<T>(l :: List<T>, item :: T)
  -> List<T>:
  doc: "removes item from list"
  
  cases (List) l:
    | empty => empty
    | link(f, r) =>
      if f == item:
        r
      else:
        link(f, my-remove(r, item))
      end
  end
end

fun get-list-max(lst :: List<Number>)
  -> Number:
  doc: "finds the maximum value of a vector"
  fold(lam(acc, n): num-max(acc, n) end, 0, lst)
end

fun recommend(title :: String, book-records :: List<File>) :
 
  doc: ```Takes in the title of a book and a list of files,
       and returns a recommendation of book(s) to be paired with title
       based on the files in book-records.```
  
  relevant-pairs = filter( #all pairs that include 'title'
    lam(p): pair-contains-title(p, title) end, 
    get-all-pairs(book-records))
  
  unique-titles = 
    
    my-remove(
      fold(lam(acc, f): add-unique(f.content, acc) end, 
      empty, 
      book-records), 
    title)
   
  title-counts = map(lam(t): count(relevant-pairs, t, pair-contains-title) end, unique-titles)
  counts-max = get-list-max(title-counts)
    
  
  recommendation(counts-max,
    filter(
      lam(x): not(is-empty(x)) end,

      map2(
        lam(t, c): 
          if not(c == counts-max) or (c == 0):
            empty
          else:
            t
          end
        end,
        unique-titles, title-counts)))
end

fun popular-pairs(records :: List<File>) -> Recommendation<BookPair>:
  doc: ```Takes in a list of files and returns a recommendation of
       the most popular pair(s) of books in records.```
  
  all-pairs = get-all-pairs(records)
  unique-pairs = fold(lam(acc, p): add-unique([list: p], acc) end, empty, all-pairs)
  pair-counts = map(lam(t): count(all-pairs, t, lam(x, y): x == y end) end, unique-pairs)
  counts-max = get-list-max(pair-counts)
  
  recommendation(counts-max,
  filter( #and, filtering the rest out
    lam(x): not(is-empty(x)) end,

  map2( #firstly, searching for all terms associated with max-count
    lam(t, c): 
      if not(c == counts-max):
        empty
      else:
        t
      end
    end,
    unique-pairs, pair-counts)))
end