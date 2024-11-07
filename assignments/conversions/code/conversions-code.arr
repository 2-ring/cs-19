use context essentials2021

provide: get-art-in-4 end

include my-gdrive("conversions-common.arr")
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# You may write implementation-specific tests (e.g., of helper functions) in this file.

## imports ##

import tables as T
include string-dict

## helpers ##

#general

fun count<T>(e :: T, l :: List<T>) -> Number:
  doc: ```Returns the number of instances of element 'e' in List 'l'.```
  cases (List) l:
    | empty => 0
    | link(f, r) =>
      val = if f == e : 1 else: 0 end
      val + count(e, r)        
  end
where:
  count(1, [list: 1, 5, 3, 1, 1, 2]) is 3
  count(3, [list: 1, 5, 3, 1, 1, 2]) is 1
  count(4, [list: 1, 5, 3, 1, 1, 2]) is 0
  count(10, empty) is 0
end

fun remove-duplicates<T>(lst :: List<T>) -> List<T>:
  doc: ```Removes all instances of any repeated terms.```
  cases (List) lst:
    | empty => empty
    | link(f, r) => 
      if count(f, lst) > 1:
        remove-duplicates(remove(r, f))
      else:
        link(f, remove-duplicates(r))
      end
  end
where:
  remove-duplicates([list: 1, 5, 3, 1, 1, 2, 2]) is [list: 5, 3]
  remove-duplicates([list: 11, 11, 10, 11, 10, 12, 12, 13]) is [list: 13]
end

#graph operations

fun edges-from(target-node :: String, graph :: Graph) -> Graph:
  doc: ```Finds all the edges connected to the 'target-node' 
       in the given Graph.```
  cases (List) graph:
    | empty => empty 
    | link(current-edge, rest-graph) =>
      cases (Conversion) current-edge:
        | conversion(u, v, _) =>
          if (u == target-node) or (v == target-node):
            link(current-edge, edges-from(target-node, rest-graph))
          else:
            edges-from(target-node, rest-graph)
          end
      end
  end 
where:
  edges-from("Dollar", cc-to-graph(connected-cyclic)) 
    is [list: 
    conversion("Pound", "Dollar", 1.29), 
    conversion("Baht", "Dollar", 0.029), 
    conversion("Dollar", "Yuan", 7.18)]
  edges-from("Dong", cc-to-graph(connected-cyclic)) 
    is [list: conversion("Yuan", "Dong", 3376)]
  edges-from("Australian Dollar", cc-to-graph(connected-cyclic)) is empty
  edges-from("Dollar", cc-to-graph(repeated-unconnected))
    is [list: conversion("Baht", "Dollar", 0.029)]
end

fun get-other-node(n :: String, c :: Conversion) -> String:
  doc: ```Returns the node contained within Conversion 'c' 
       other than the given node 'n'.```
  cases (Conversion) c:
    | conversion(u, v, _) =>
      if u == n:
        v
      else:
        u
      end
  end
where:
  get-other-node("Baht", conversion("Baht", "Dollar", 0.029)) is "Dollar"
  get-other-node("Dong", conversion("Yuan", "Dong", 3376)) is "Yuan"
  get-other-node("Yuan", conversion("Dollar", "Yuan", 7.18)) is "Dollar"
end

fun cc-to-graph(cc :: Table) -> Graph:
  doc: ```Converts the currency conversion Table 'cc' to a 
       a Graph, represented as a list of edges. Omits all 
       instances of any duplicate edges.```
  rows = cc.all-rows()
  unsantised = map({(row):  
      conversion(row["from-c"], row["to-c"], row["conv-rate"])}, rows)
  remove-duplicates(unsantised)
where:
  cc-to-graph(repeated-unconnected) 
    is [list: 
    conversion("Pound", "Baht", 44.3), 
    conversion("Baht", "Dollar", 0.029), 
    conversion("Yuan", "Kip", 3042.59), 
    conversion("Yuan", "Dong", 3376)]
  cc-to-graph(totally-unconnected) 
    is [list: 
    conversion("Pound", "Dong", 32706.52), 
    conversion("Baht", "Dollar", 0.029), 
    conversion("Yuan", "Kip", 3042.59)]
  cc-to-graph(conversion-empty) is empty
end

fun edge-to-string(edge :: Conversion) -> String:
  doc: ```Converts the given edge to a String in a consistent manner.```
  cases (Conversion) edge:
    | conversion(source, destination, _) =>
      #sorting alphabetically for standardisation
      if source > destination: 
        source + '-' + destination
      else: 
        destination + '-' + source
      end
  end
where:
  edge-to-string(conversion("Pound", "Dollar", 1.3)) is "Pound-Dollar"
  edge-to-string(conversion("Dollar", "Pound", 1.3)) is "Pound-Dollar"
  edge-to-string(conversion("Yuan", "Kip", 3042.59)) is "Yuan-Kip"
end

#problem specific
fun path-between(
    start :: String, 
    target :: String,
    graph :: Graph) 
  -> Option<Graph>:
  doc: ```Finds the list of edges that form the path from the 'start' node 
       to the 'target' node in given Graph.```
  
  fun visit-node(
      node :: String, 
      visited-edges:: StringDict)
    -> Option<List>:
    doc: ```Performs the next recursive step of the depth-first search 
         from the given 'node'.```
    if node == target: #if arrived at target node
      some(empty)
    else:
      connected-edges = edges-from(node, graph) #finding all connected edges
      #filtering out already visited edges
      unvisited-edges = filter(
        {(e): 
          not(visited-edges.get-value(edge-to-string(e)))
        }, connected-edges)
      #finding which node each unvisited edge leads to
      unvisted-nodes = map({(e): get-other-node(node, e)}, unvisited-edges)
      #updating which edges have been visited with the new edges
      new-visited-edges = fold(
        {(acc, e): acc.set(edge-to-string(e), true)}, 
        visited-edges, unvisited-edges)

      #following each connected edge
      fold2({(acc, destination-node, edge):
          #if correct path not yet folded over
          if acc == none: 
            #follow path to next node
            is-correct-path = visit-node(destination-node, new-visited-edges)
            cases (Option) is-correct-path:
              | none => none #path is wrong so return none
              | some(next-edge) => #path is correct
                some(link(edge, next-edge)) #so return it up the stack frame
            end
            #if correct path already folded over
          else: 
            acc #skip the current node
          end}, 
        none, unvisted-nodes, unvisited-edges)
    end
  end

  visted-edges = fold(
    {(acc, e): acc.set(edge-to-string(e), false)}, 
    [string-dict:], graph) 
  visit-node(start, visted-edges)
where:
  path-between("Pound", "Dong", cc-to-graph(totally-unconnected)) 
    is some([list: conversion("Pound", "Dong", 32706.52)])
  path-between("Baht", "Yuan", cc-to-graph(connected-cyclic)) 
    is some([list: 
      conversion("Pound", "Baht", 44.3), 
      conversion("Pound", "Dollar", 1.29), 
      conversion("Dollar", "Yuan", 7.18)])
  path-between("Kip", "Pound", cc-to-graph(repeated-still-connected)) 
    is some([list: 
      conversion("Yuan", "Kip", 3042.59), 
      conversion("Dollar", "Yuan", 7.18), 
      conversion("Baht", "Dollar", 0.029), 
      conversion("Pound", "Baht", 44.3)])
  path-between("Baht", "Yuan", cc-to-graph(repeated-unconnected)) is none
  path-between("Pound", "Kip", cc-to-graph(totally-unconnected)) is none
end

fun path-rate(
    path :: Graph, 
    target-currency :: String):
  doc: ```Takes a valid path of edges and calculates the conversion 
       rate when following it to the 'target-currency'.```
  fun helper(remaining-path):
    cases (List) remaining-path:
      | empty => 1
      | link(current, rest) =>
        next-currency = cases (List) rest:
          | empty => 
            target-currency
          | link(next, _) =>
            #if next.from-c in current edge
            if (next.from-c == current.from-c) 
              or (next.from-c == current.to-c):
              next.from-c #it is the next currency
            else:
              next.to-c
            end
        end
        #if rate already in correct direction
        rate = if current.to-c == next-currency: 
          current.conv-rate
        else: #else invert the conversion rate
          1 / current.conv-rate
        end
        rate * helper(rest)
    end
  end
  helper(path)
where:
  path-rate([list: 
      conversion("Euros", "Australian Dollar", 163/100), 
      conversion("Riel", "Australian Dollar", 9/25000), 
      conversion("Riel", "Pounds", 19/100000)], "Pounds") 
    is-roughly 0.86027777777
  path-rate([list: conversion("Pound", "Dong", 32706.52)], "Dong") 
    is 32706.52
  path-rate([list: conversion("Pound", "Dong", 32706.52)], "Pound") 
    is 25/817663
  path-rate([list: 
      conversion("Pound", "Baht", 44.3), 
      conversion("Pound", "Dollar", 1.29), 
      conversion("Dollar", "Yuan", 7.18)], "Yuan") 
    is 46311/221500
  path-rate([list: 
      conversion("Yuan", "Kip", 3042.59), 
      conversion("Dollar", "Yuan", 7.18), 
      conversion("Baht", "Dollar", 0.029), 
      conversion("Pound", "Baht", 44.3)], "Pound") 
    is-roughly 0.00003563119582
end

## required functions ##

fun get-art-in-4(
    art :: Table, 
    cc :: Table, 
    art-id :: Number, 
    currency :: String) 
  -> Number:
  doc: ```Returns the price of the given artwork in the specified 
       currency. If there are missing or duplicate entries in the 
       art table, or if conversion is not possible it raises an error. 
       Valid conversions can be listed in either direction but not be
       listed more than once in either.```
  art-id-matches = 
    select 
      cost, currency from
      (sieve art using id: id == art-id end)
    end
  len-art = art-id-matches.length()
  ask:
    | len-art == 0 then: raise("art-id invalid: missing")
    | len-art > 1 then: raise("art-id invalid: duplicate")
    | otherwise:
      art-info = art-id-matches.row-n(0)
      og-currency = art-info["currency"]
      currency-graph = cc-to-graph(cc)
      path-exists = path-between(og-currency, currency, currency-graph)
      cases (Option) path-exists:
        | none =>
          raise("conversion invalid: missing")
        | some(conversion-path) => 
          art-info["cost"] * path-rate(conversion-path, currency)
      end
  end
end