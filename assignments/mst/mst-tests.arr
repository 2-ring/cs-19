use context essentials2021
include shared-gdrive("mst-definitions.arr", "1BGkPeyFNhp0ND5sENwAXbL-BgQ9ZB_Nt")

include my-gdrive("mst-common.arr")
import mst-prim, mst-kruskal, generate-input, mst-cmp, sort-o-cle
  from my-gdrive("mst-code.arr")
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# Write your examples and tests in here. These should not be tests of
# implementation-specific details (e.g., helper functions).

## imports ##

include string-dict

## mst-kruskal ##

check "empty input":
  mst-prim(empty) is empty
end

check "one edge":
  mst-kruskal(letters-graph-2) 
    is [list: edge("X", "Y", 4)]
end

check "dense input":
  mst-kruskal(fully-connected-4) 
    is [list: 
    edge("D", "B", -1),
    edge("A", "D", -3), 
    edge("A", "C", -8)]
end

check "sparse input":
  mst-kruskal(tree-6) 
    is [list: 
    edge("D", "E", 7), 
    edge("A", "B", 5), 
    edge("B", "C", 3), 
    edge("B", "E", 2), 
    edge("D", "F", 1)]
end

check "standard input":
  mst-kruskal(letters-graph-3) 
    is [list: 
    edge("B", "C", 3), 
    edge("A", "B", 2)]
  mst-kruskal(letters-graph-5) 
    is [list: 
    edge("Y", "U", 7), 
    edge("Z", "W", 5), 
    edge("X", "Y", 4), 
    edge("Y", "W", 2)]
  mst-kruskal(letters-graph-6) 
    is [list: 
    edge("A", "B", 5), 
    edge("D", "E", 3), 
    edge("B", "C", 3), 
    edge("B", "E", 2), 
    edge("D", "F", 1)]
  mst-kruskal(letters-graph-7) 
    is [list: 
    edge("P", "Q", 3), 
    edge("V", "T", 3), 
    edge("S", "U", 2), 
    edge("Q", "R", 2), 
    edge("S", "V", 1), 
    edge("R", "T", 1)]
end

## mst-prim ##

check "empty input":
  mst-prim(empty) is empty
end

check "one edge":
  mst-prim(letters-graph-2) 
    is [list: edge("X", "Y", 4)]
end

check "dense input":
  mst-kruskal(fully-connected-4) 
    is [list: 
    edge("D", "B", -1), 
    edge("A", "D", -3), 
    edge("A", "C", -8)]
end

check "sparse input":
  mst-kruskal(tree-6) 
    is [list: 
    edge("D", "E", 7), 
    edge("A", "B", 5), 
    edge("B", "C", 3), 
    edge("B", "E", 2), 
    edge("D", "F", 1)]
end

check "standard input":
  mst-prim(letters-graph-3) 
    is [list: 
    edge("B", "C", 3), 
    edge("A", "B", 2)]
  mst-prim(letters-graph-5) 
    is [list: 
    edge("Y", "U", 7), 
    edge("Y", "W", 2), 
    edge("X", "Y", 4), 
    edge("Z", "W", 5)]
  mst-prim(letters-graph-6) is 
  [list: 
    edge("D", "F", 1), 
    edge("D", "E", 3), 
    edge("B", "E", 2), 
    edge("B", "C", 3), 
    edge("A", "B", 5)]
  mst-prim(letters-graph-7) is 
  [list: 
    edge("S", "V", 1), 
    edge("S", "U", 2), 
    edge("V", "T", 3), 
    edge("R", "T", 1), 
    edge("Q", "R", 2), 
    edge("P", "Q", 3)]
end

## generate-input ##

#constants
MAX-WEIGHT = 10000
RANDOM-TESTS = 50
MAX-GRAPH-ORDER = 10

#helper
fun whole-list-satisfies<T>(
    predicate :: (T -> Boolean), 
    lst :: List<T>) -> Boolean:
  doc: ```Determines if the given 'predicate' returns 'true' for 
       all terms in the given List```
  cases (List) lst:
    | empty => true
    | link(first, rest) => 
      predicate(first) and whole-list-satisfies(predicate, rest)
  end
end

#random input
random-inputs = map({(x): 
    graph-order = num-random(MAX-GRAPH-ORDER - 1) + 2
    generate-input(graph-order)},
  range(0, RANDOM-TESTS))
result-10 = generate-input(10)
nodes-10 = get-all-nodes(result-10)

check "feature based testing":
  nodes-10.length() is 10 #edge has as many nodes as expected
  whole-list-satisfies(is-connected, random-inputs) is true
  whole-list-satisfies(is-edge, result-10) is true
  whole-list-satisfies({(e):
      cases (Edge) e:
        | edge(u, v, w) =>
          member(nodes-10, u) #all edges generated are within the given node
          and member(nodes-10, v) 
          and (w <= MAX-WEIGHT) #all weights are in the expected range
          and (w >= (-1 * MAX-WEIGHT))
      end}, result-10) is true
end

check "empty result":
  generate-input(0) is empty
  generate-input(1) is empty
end

## mst-cmp ##

trees = map(mst-kruskal, random-inputs)
check "same solutions":
  fold2({(acc, input, tree): 
      tree-shuffled = shuffle(tree)
      mst-cmp(input, tree, tree-shuffled) and acc}, 
    true, random-inputs, trees) is true
end

check "different solutions but valid":
  mst-cmp(letters-graph-6,
    [list:
      edge("A", "B", 5),
      edge("C", "D", 8),
      edge("D", "E", 3),
      edge("D", "F", 1),
      edge("B", "E", 2)],
    [list:
      edge("A", "B", 5),
      edge("B", "C", 3),
      edge("C", "D", 8),
      edge("D", "F", 1),
      edge("B", "E", 2)]) is true
end

check "completley different":
  mst-cmp(letters-graph-6,
    letters-graph-2,
    letters-graph-7) is false
end

check "not connected":
  mst-cmp(letters-graph-5,
    [list:
      edge("X", "Y", 4),
      edge("X", "W", 6),
      edge("Z", "W", 5),
      edge("Y", "U", 7)],
    [list:
      edge("X", "Y", 4),
      edge("Y", "W", 2),
      edge("Z", "W", 5),
      edge("Y", "U", 7)]) is false
end

check "same structure, different nodes":
  mst-cmp(letters-graph-3,
    [list:
      edge("A", "B", 2),
      edge("B", "C", 3)],
    [list:
      edge("X", "Y", 2),
      edge("Y", "Z", 3)]) is false
end

check "not tree":
  mst-cmp(letters-graph-7,
    [list:
      edge("P", "Q", 3),
      edge("P", "R", 4),
      edge("Q", "R", 2),
      edge("Q", "S", 5),
      edge("R", "S", 6),
      edge("R", "T", 1),
      edge("S", "U", 2),
      edge("S", "V", 1),
      edge("V", "T", 3),
      edge("V", "U", 9)],
    [list: 
      edge("S", "V", 1), 
      edge("S", "U", 2), 
      edge("V", "T", 3), 
      edge("R", "T", 1), 
      edge("Q", "R", 2), 
      edge("P", "Q", 3)])
end

## sort-o-cle ##

#incorrect implementations

#1
fun original-graph(graph :: Graph) -> Graph:
  graph
end

#2
fun drop-randomly(graph :: Graph) -> Graph:
  to-drop = num-random(graph.length())
  graph.drop(to-drop)
end

#3
fun kruskal-every-edge(
    current-tree :: Graph,
    sets-dict :: StringDict<Element>,
    remaining-edges :: EdgeHeap) 
  -> Graph:
  if current-tree.length() >= (sets-dict.count() - 1):
    current-tree
  else:
    next-lightest = get-min(remaining-edges)
    rest-edges = remove-min(remaining-edges)
    new-tree =
      cases (Edge) next-lightest block:
        | edge(u, v, _) =>
          u-element = sets-dict.get-value(u)
          v-element = sets-dict.get-value(v)
          union(u-element, v-element)
          link(next-lightest, current-tree)
      end
    kruskal-every-edge(new-tree, sets-dict, rest-edges)
  end
end

fun kruskal-no-check(graph :: Graph) -> Graph:
  edge-heap = add-list-to-heap(graph, mt)
  all-nodes = get-all-nodes(graph)
  sets-dict = fold(
    {(acc, n): acc.set(n, element(n, none))}, 
    [string-dict:], all-nodes)
  kruskal-every-edge(empty, sets-dict, edge-heap)
end

#4
fun until-cycle-found(
    sets-dict :: StringDict<Element>,
    remaining-edges :: Graph) 
  -> Graph:
  cases (List) remaining-edges:
    | empty => empty
    | link(next-edge, rest-edges) =>
      cases (Edge) next-edge:
        | edge(u, v, _) =>
          u-element = sets-dict.get-value(u)
          v-element = sets-dict.get-value(v)
          if is-in-same-set(u-element, v-element) block:
            [list: next-edge]
          else:
            union(u-element, v-element)
            link(next-edge, until-cycle-found(sets-dict, rest-edges))
          end
      end
  end
end

fun path-until-cycle(graph :: Graph) -> Graph:
  all-nodes = get-all-nodes(graph)
  sets-dict = fold(
    {(acc, n): acc.set(n, element(n, none))}, 
    [string-dict:], all-nodes)
  until-cycle-found(sets-dict, graph)
end

#5
fun half-graph(graph :: Graph) -> Graph:

  cases (List) graph:
    | empty => empty
    | link(f, r) =>
      cases (List) r:
        | empty => [list: f]
        | link(_, _) =>
          split-at(num-round(graph.length() / 2), r).prefix
      end
  end
end

#6
fun prims-minus-one(graph:: Graph) -> Graph:
  cases (List) empty:
    | empty => empty
    | link(_, _) => mst-prim(graph).drop(1)
  end
end

#7
fun always-empty(graph:: Graph) -> Graph:
  empty
end

#testing
check "both correct":
  sort-o-cle(mst-kruskal, mst-prim) is true
end

check "only one correct":
  sort-o-cle(kruskal-no-check, mst-prim) is false
  sort-o-cle(kruskal-no-check, mst-kruskal) is false

  sort-o-cle(original-graph, mst-prim) is false
  sort-o-cle(drop-randomly, mst-prim) is false
  sort-o-cle(path-until-cycle, mst-prim) is false

  sort-o-cle(half-graph, mst-kruskal) is false
  sort-o-cle(prims-minus-one, mst-kruskal) is false
  sort-o-cle(always-empty, mst-kruskal) is false
end

check "both wrong":
  sort-o-cle(kruskal-no-check, path-until-cycle) is false
  sort-o-cle(drop-randomly, always-empty) is false
  sort-o-cle(path-until-cycle, prims-minus-one) is false
  sort-o-cle(original-graph, half-graph) is false
end