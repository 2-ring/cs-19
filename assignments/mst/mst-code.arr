use context essentials2021
include shared-gdrive("mst-definitions.arr", "1BGkPeyFNhp0ND5sENwAXbL-BgQ9ZB_Nt")

provide: mst-prim, mst-kruskal, generate-input, mst-cmp, sort-o-cle end

include my-gdrive("mst-common.arr")
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# You may write implementation-specific tests (e.g., of helper functions)
# in this file.

## imports ##

include string-dict

## union find ##
#in mst-common.arr

## edge heap ##
#in mst-common.arr

## general helpers ##

fun contains-other-list(l1, l2):
  doc: ```Irrelevant of duplicates, determines whether all terms 
       in 'l2' are also contained within 'l1'.```
  cases (List) l2:
    | empty => true
    | link(f, r) =>
      member(l1, f) and contains-other-list(l1, r)
  end
where:
  contains-other-list([list: 1, 2, 3], [list: 3, 2, 3, 3]) is true
  contains-other-list([list: 1, 2, 3], [list: ]) is true
  contains-other-list([list: 1, 2, 3], [list: 3, 2, 1, 4]) is false
end

#Other helpers:
#random-choice,
#get-all-nodes,
#get-other-node,
#edges-from,
#in mst-common.arr.

## required functions ##

## mst-prim ##

#helpers

fun find-unconnected-node(
    e :: Edge, 
    connected-nodes :: StringDict<Boolean>) 
  -> Option<Edge>:
  doc: ```Returns the node contained within edge 'e' that is not 
       already connected (assuming one or none of the nodes are connected).```
  cases (Edge) e:
    | edge(u, v, _) =>
      ask:
        | not(connected-nodes.get-value(u)) then: some(u)
        | not(connected-nodes.get-value(v)) then: some(v)
        | otherwise: none
      end
  end
where:
  find-unconnected-node(edge("1", "4", 9400),
    [string-dict: "3", true, "5", false, "1", true, "2", true, "4", true]) is none
  find-unconnected-node(edge("A", "B", 5),
    [string-dict: "A", true, "B", false, "2", true, "C", true, "D", true]) is some("B")
end

fun next-values(
    edge-heap :: EdgeHeap,
    connected-nodes :: StringDict<Boolean>) 
  -> {String; Edge; EdgeHeap}:
  doc: "Finds the next valid edge within the heap, and returns the associated values"
  current-edge = get-min(edge-heap)
  rest-heap = remove-min(edge-heap)
  edge-is-valid = find-unconnected-node(current-edge, connected-nodes)
  cases (Option) edge-is-valid:
    | none => next-values(rest-heap, connected-nodes)
    | some(unconnected-node) => {unconnected-node; current-edge; rest-heap}
  end
where:
  next-values(node(edge("1", "5", 9068), node(edge("1", "4", 9400), mt, mt), mt),
    [string-dict: "3", true, "5", false, "1", true, "2", true, "4", true])
    is {"5"; edge("1", "5", 9068); node(edge("1", "4", 9400), mt, mt)}
  next-values(
    node(edge("B", "C", -2), node(edge("D", "A", 0), mt, mt), node(edge("A", "B", 5), mt, mt)),
    [string-dict: "A", true, "5", false, "B", true, "2", true, "C", false, "D", true])
    is {"C"; edge("B", "C", -2); node(edge("D", "A", 0), node(edge("A", "B", 5), mt, mt), mt)}
end

fun all-values-true(dict :: StringDict) -> Boolean:
  doc: "Determines if all values in the given StringDict are 'true'"
  all-keys = dict.keys()
  all-keys.fold({(acc, key): dict.get-value(key) and acc}, true)
where:
  all-values-true([string-dict: "a", true, "b", true, "c", true]) is true
  all-values-true([string-dict: "a", true, "b", false, "c", true]) is false
  all-values-true([string-dict: "a", true]) is true
end

#main

fun prim-next-edge(
    connected-nodes :: StringDict<Boolean>, 
    edge-heap :: EdgeHeap,
    graph :: Graph) -> Graph:
  if all-values-true(connected-nodes):
    empty
  else:
    #next step
    {unseen-node; valid-edge; rest-heap} = 
      next-values(edge-heap, connected-nodes)
    new-edges = edges-from(unseen-node, graph)
    with-new-edges = add-list-to-heap(new-edges, edge-heap)
    now-connected-nodes = connected-nodes.set(unseen-node, true)
    #recursive call
    link(valid-edge,
      prim-next-edge(
        now-connected-nodes, 
        with-new-edges, 
        graph))
  end
end

fun mst-prim(graph :: Graph) -> Graph:
  all-nodes = get-all-nodes(graph)
  boolean-dict = fold(
    {(acc, n): acc.set(n, false)}, 
    [string-dict:], all-nodes) 
  cases (List) all-nodes:
    | empty => empty
    | link(any-node, _) => 
      starting-edges = add-list-to-heap(edges-from(any-node, graph), mt)
      connected-nodes = boolean-dict.set(any-node, true)
      prim-next-edge(connected-nodes, starting-edges, graph)
  end
end

## mst-kruskal ##

fun kruskal-next-edge(
    current-tree :: Graph,
    sets-dict :: StringDict<Element>,
    remaining-edges :: EdgeHeap) 
  -> Graph:
  doc: ```The main recursive step in finding a MST of the given g
       raph using Kruskal's Algorithm.```
  if current-tree.length() >= (sets-dict.count() - 1):
    current-tree
  else:
    next-lightest = get-min(remaining-edges)
    rest-edges = remove-min(remaining-edges)
    new-tree =
      cases (Edge) next-lightest:
        | edge(u, v, _) =>
          u-element = sets-dict.get-value(u)
          v-element = sets-dict.get-value(v)
          if is-in-same-set(u-element, v-element) block:
            current-tree
          else:
            union(u-element, v-element)
            link(next-lightest, current-tree)
          end
      end
    kruskal-next-edge(new-tree, sets-dict, rest-edges)
  end
end

fun mst-kruskal(graph :: Graph) -> Graph:
  doc: ```Finds a MST in the given Graph. Formats the given Graph as 
       needed then calls a helper function to perform the main computation.```
  edge-heap = add-list-to-heap(graph, mt)
  all-nodes = get-all-nodes(graph)
  sets-dict = fold(
    {(acc, n): acc.set(n, element(n, none))}, 
    [string-dict:], all-nodes)
  kruskal-next-edge(empty, sets-dict, edge-heap)
end

## generate-input ##

#helpers

fun generate-nodes(amount :: Number) -> List:
  doc: ```Returns an increasing list of number strings from "1" to 
       the number specified by 'amount'.```
  map({(n): num-to-string(n)}, range(1, amount + 1))
where:
  generate-nodes(6) is [list: "1", "2", "3", "4", "5", "6"]
  generate-nodes(0) is empty
  generate-nodes(3) is [list: "1", "2", "3"]
end  

fun random-weight() -> Number:
  doc: "Returns a random number between +/- MAX-WEIGHT."
  MAX-WEIGHT = 10000
  magnitude = num-random(MAX-WEIGHT + 1)
  sign = if num-random(2) == 1: -1 else: 1 end
  sign * magnitude
where:
  MAX-WEIGHT = 10000 #because previous defenition is local
  fold({(acc, n): w = random-weight() #each test
      is-number(w) #is a number
      and (w <= MAX-WEIGHT) #within the expected range
      and (w >= (-1 * MAX-WEIGHT)) 
      and acc}, 
    true, range(0, 20)) is true
end

fun random-tree(nodes :: List<String>) -> Graph:
  doc: ```Generates a random tree as a list of edges 
       using the elements within 'nodes'.```
  fun helper(
      connected :: List<String>, 
      unconnected :: List<String>) -> Graph:
    cases (List) unconnected:
      | empty => empty
      | link(_, _) =>
        current-node = random-choice(connected)
        number-of-edges = num-random(unconnected.length()) + 1
        connect-to = shuffle(unconnected).take(number-of-edges)
        #values for the next next recursive call
        new-unconnected = 
          filter({(x): not(member(connect-to, x))}, unconnected)
        new-connected = remove((connected + connect-to), current-node)
        new-edges = map( #generating new edges
          {(x): edge(current-node, x, random-weight())}, connect-to)
        new-edges + helper(new-connected, new-unconnected)
    end
  end

  cases (List) nodes:
    | empty => empty
      #can start from first because the input nodes are randomly generated
    | link(f, r) => helper([list: f], r)
  end
where: 
  fold({(acc, x): 
      is-tree(random-tree(generate-nodes(10))) and acc}, 
    true, range(0, 15)) is true
  random-tree(empty) is empty
end

fun generate-edges(nodes :: List<String>, quantity :: Number) -> Graph:
  doc: ```Generates randomised edges with the given 'nodes'. Generates 
       the given 'quantity' and returns them in a list. 'nodes' must 
       contain at least two elements.```
  if (quantity <= 0) or (nodes.length() < 2):
    empty
  else:
    u = random-choice(nodes)
    v = random-choice(remove(nodes, u))
    link(
      edge(u, v, random-weight()),
      generate-edges(nodes, quantity - 1))
  end
where:
  generate-edges([list: "A", "B", "C"], 2) satisfies is-link
  generate-edges([list: "A", "B", "C"], 5).get(3) satisfies is-edge
  generate-edges([list: "A", "B", "C"], 0) is empty
end

fun node-order-in-graph(target-e :: Edge, graph :: Graph) -> Boolean:
  doc: ```Determines whether any edges containing certain nodes in a 
       specific order are in the graph.```
  cases (List) graph:
    | empty => false
    | link(current-e, r) =>
      if (target-e.a == current-e.a) and (target-e.b == current-e.b):
        true
      else:
        node-order-in-graph(target-e, r)
      end
  end
where: 
  node-order-in-graph(edge("Z", "W", 28), letters-graph-5) is true
  node-order-in-graph(edge("W", "Z", 10), letters-graph-5) is false
  node-order-in-graph(edge("Y", "X", 1), letters-graph-2) is false
end

fun sanitise-graph(
    sanitised :: Graph, 
    unsanitised :: Graph) -> Graph:
  doc: ```Ensures all the 'unsantised' edges are formatted correctly 
       according to the 'santised'  edges. This is to account for the
       graph's undirected quality--every edge connecting any two nodes 
       must store the nodes in the same order.```
  cases (List) unsanitised:
    | empty => sanitised
    | link(e, r) =>
      cases (Edge) e:
        | edge(u, v, w) => 
          reverse-e = edge(v, u, w)
          new-sanitised = link(
            if node-order-in-graph(reverse-e, sanitised):
              reverse-e
            else:
              e
            end, sanitised)
          sanitise-graph(new-sanitised, r)
      end
  end
where:
  sanitise-graph(letters-graph-5, 
    [list:
      edge("A", "B", 2),
      edge("A", "C", 5),
      edge("C", "A", 1),
      edge("B", "C", 3),
      edge("C", "B", 7)]) 
    is 
  [list:
    edge("B", "C", 7), 
    edge("B", "C", 3), 
    edge("A", "C", 1), 
    edge("A", "C", 5), 
    edge("A", "B", 2), 
    edge("X", "Y", 4), 
    edge("X", "W", 6), 
    edge("Y", "W", 2), 
    edge("Z", "W", 5), 
    edge("Y", "U", 7)]
  sanitise-graph(letters-graph-5, 
    [list:
      edge("X", "W", 6),
      edge("W", "X", 6),
      edge("X", "W", 6),
      edge("Y", "U", 7),
      edge("U", "Y", 7)]) 
    is 
  [list: 
    edge("Y", "U", 7), 
    edge("Y", "U", 7), 
    edge("X", "W", 6), 
    edge("X", "W", 6), 
    edge("X", "W", 6), 
    edge("X", "Y", 4), 
    edge("X", "W", 6), 
    edge("Y", "W", 2), 
    edge("Z", "W", 5), 
    edge("Y", "U", 7)]
end

fun populate-tree(tree :: Graph, nodes :: List<String>) -> Graph:
  doc: ```Generates and adds random edges to the given 'tree'. The 
       new edges are randomly generated from the pool of 'nodes' given. Up to
       MAX-MULTIPLIER times the number of nodes initially in the given 'tree' 
       can be added.```
  MAX-MULTIPLIER = 3 #how many times more edges than prexisting nodes can be added
  num-edges = num-random(MAX-MULTIPLIER * nodes.length())
  new-edges = generate-edges(nodes, num-edges) #edges to be added
  sanitise-graph(tree, new-edges) 
where:
  MAX-MULTIPLIER = 3 #other defenition is local
  test-nodes = generate-nodes(5)
  test-tree = random-tree(test-nodes)
  result = populate-tree(test-tree, test-nodes)
  #number of nodes added is within bounds
  (result.length() >= test-tree.length()) is true
  (result.length() <= (test-tree.length() + (test-nodes.length() * MAX-MULTIPLIER))) is true
  #generating only nodes
  fold({(acc, x): is-edge(x) and acc}, true, result) is true
  #made from only elements in nodes
  member(test-nodes, result.get(3).a) is true
end

#main

fun generate-input(num-vertices :: Number) -> Graph:
  doc: ```Generates a valid, well-formed, randomised, graph 
  input. The graph contains 'num-vertices' nodes.```
  if num-vertices < 2:
    empty
  else:
    nodes = generate-nodes(num-vertices)
    ran-tree = random-tree(nodes)
    populate-tree(ran-tree, nodes)
  end
end

## mst-cmp ##

fun is-acyclic-helper( #tested with the below function
    sets-dict :: StringDict<Element>,
    remaining-edges :: Graph) 
  -> Boolean:
  doc: ```Determines whether the given graph has a cycle. Does so by traversing 
       the graph until either no edges are left or a cycle is found.```
  cases (List) remaining-edges:
    | empty => true
    | link(next-edge, rest-edges) =>
      cases (Edge) next-edge:
        | edge(u, v, _) =>
          u-element = sets-dict.get-value(u)
          v-element = sets-dict.get-value(v)
          if is-in-same-set(u-element, v-element) block:
            false
          else:
            union(u-element, v-element)
            is-acyclic-helper(sets-dict, rest-edges)
          end
      end
  end
end

fun is-acyclic(graph:: Graph) -> Boolean:
  doc: ```Determines whether the given graph has a cycle. Formats the input and calls 
       a helper to do most the computation.```
  all-nodes = get-all-nodes(graph)
  sets-dict = fold(
    {(acc, n): acc.set(n, element(n, none))}, 
    [string-dict:], all-nodes)
  is-acyclic-helper(sets-dict, graph)
where:
  letters-graph-2 satisfies is-acyclic
  not-connected-4 satisfies is-acyclic
  [list: edge("A", "B", 2), edge("A", "C", 5)] satisfies is-acyclic
  letters-graph-2 satisfies is-acyclic
  not-connected-5 violates is-acyclic
  letters-graph-3 violates is-acyclic
  letters-graph-5 violates is-acyclic
  letters-graph-6 violates is-acyclic
  letters-graph-7 violates is-acyclic
end

#get-reachable-nodes
#in mst-common.arr

#is-connected
#in mst-common.arr

fun is-tree(graph :: Graph) -> Boolean:
  doc: ```Determines whether the given Graph represents a tree: i.e. is connected, acyclic 
       and contains one fewer edge than node.```
  all-nodes = get-all-nodes(graph)
  ((all-nodes.length() - 1) == graph.length()) #one less edge than node
  and is-connected(graph)
  and is-acyclic(graph)
where:
  letters-graph-2 satisfies is-tree
  letters-graph-7 violates is-tree
  empty violates is-tree #wikipedia said an empty graph isnt a tree
end

fun is-spanning(other-graph :: Graph, original-graph :: Graph) -> Boolean:
  doc: ```Determines whether the 'other-graph' contains all 
       the exact same nodes as 'orginal-graph'.```
  original-nodes = get-all-nodes(original-graph)
  other-nodes = get-all-nodes(other-graph)
  contains-other-list(original-nodes, other-nodes)
  and (original-nodes.length() == other-nodes.length())
where:
  is-spanning(mst-kruskal(letters-graph-7), letters-graph-7) is true
  is-spanning(letters-graph-5, letters-graph-5) is true
  is-spanning([list:
      edge("X", "Y", 4),
      edge("X", "W", 6),
      edge("Z", "W", 5),
      edge("Y", "U", 7)], letters-graph-5) is true
  is-spanning(not-connected-5, not-connected-4) is false
  is-spanning([list: edge("A", "B", 4)], letters-graph-2) is false
end

fun total-weight(graph :: Graph) -> Number:
  doc: ```Calculates the cumalative weight of all edges in the given Graph.```
  cases (List) graph:
    | empty => 0
    | link(next-edge, rest) =>
      cases (Edge) next-edge:
        | edge(_, _, w) => 
          w + total-weight(rest)
      end
  end
where:
  total-weight(letters-graph-6) is 32
  total-weight(letters-graph-5) is 24
  total-weight(empty) is 0
  total-weight(letters-graph-2) is 4
  total-weight(letters-graph-3) is 10
  total-weight(letters-graph-7) is 40
end

fun is-subgraph(subgraph :: Graph, graph :: Graph) -> Boolean:
  doc: ```Determines whether the 'subgraph' only contains 
       edges also included within 'graph'.```
  contains-other-list(graph, subgraph)
where:
  is-subgraph([list:
      edge("A", "B", 5),
      edge("A", "C", 10),
      edge("B", "C", 3)],
    letters-graph-6) is true
  is-subgraph([list:
      edge("A", "B", 6),
      edge("A", "C", 10),
      edge("B", "C", 3)],
    letters-graph-6) is false
  is-subgraph([list:
      edge("A", "F", 20),
      edge("A", "C", 10),
      edge("B", "E", 2)],
    letters-graph-6) is false
  is-subgraph([list:
      edge("C", "D", 8),
      edge("B", "E", 2),
      edge("B", "C", 3),
      edge("D", "F", 1)],
    letters-graph-6) is true
  is-subgraph(empty, letters-graph-6) is true
end

#main

fun mst-cmp(
    graph :: Graph,
    mst-a :: Graph,
    mst-b :: Graph)
  -> Boolean:
  doc: ```As described in the handout.```
  #Both solutions are: trees, 
  ((is-tree(mst-a) and is-tree(mst-a)) or is-empty(graph))
  #spanning, 
  and (is-spanning(mst-a, graph) and is-spanning(mst-a, graph))
  #have the same weight, 
  and (total-weight(mst-a) == total-weight(mst-b))
  #and only contain edges in the original graph.
  and (is-subgraph(mst-a, graph) and is-subgraph(mst-b, graph))
end

## sort-o-cle ##

fun sort-o-cle(
    mst-alg-a :: (Graph -> Graph),
    mst-alg-b :: (Graph -> Graph))
  -> Boolean:
  doc: ```As described in the handout.```
  #random
  RANDOM-TESTS = 50
  MAX-GRAPH-ORDER = 10
  random-inputs = map({(x): 
      graph-order = num-random(MAX-GRAPH-ORDER - 1) + 2 #excluding empty graphs from random tests
      generate-input(graph-order)},
    range(0, RANDOM-TESTS))
  #manual
  manual-inputs = [list:
    empty, #0 or 1 node graph
    letters-graph-2, #1 edge graph
    letters-graph-3, #3 node cycle
    fully-connected-4, #4 node fully connected graph
    tree-6, #a tree with 6 nodes
    [list:
      edge("A", "B", 1), #10 node cycle
      edge("B", "C", 1),
      edge("C", "D", 1),
      edge("D", "E", 1),
      edge("E", "F", 1),
      edge("F", "G", 1),
      edge("G", "H", 1),
      edge("H", "I", 1),
      edge("I", "J", 1),
      edge("J", "A", 1)], 
    [list:
      edge("A", "B", 23), #all same weight
      edge("B", "C", 23),
      edge("C", "D", 23),
      edge("D", "A", 23),
      edge("A", "C", 23),
      edge("B", "D", 23)],
    [list:
      edge("A", "B", 0), #all weights 0
      edge("B", "C", 0),
      edge("C", "D", 0),
      edge("D", "A", 0)], 
    [list:
      edge("A", "B", 5), #multiple edges between same nodes
      edge("A", "B", 2),
      edge("A", "B", 12),
      edge("B", "C", 1),
      edge("C", "D", 14),
      edge("A", "D", 11)], 
    [list:
      edge("A", "B", 12), #multiple edges between same nodes, with same weight
      edge("A", "B", 12),
      edge("A", "B", 12),
      edge("B", "C", 1),
      edge("C", "D", 14),
      edge("C", "D", 14),
      edge("A", "D", 11)], 
    [list:
      edge("A", "B", 312), #all connected to only same node
      edge("A", "C", 560),
      edge("A", "D", 100),
      edge("A", "E", 89)]]
  #running the funcions on the inputs
  all-inputs = random-inputs + manual-inputs
  alg-a-results = map({(input): mst-alg-a(input)}, all-inputs)
  alg-b-results = map({(input): mst-alg-b(input)}, all-inputs)
  #comparing all results
  pass-all-tests = fold3(
    {(acc, input, a-result, b-result): 
      mst-cmp(input, a-result, b-result) and acc}, 
    true, all-inputs, alg-a-results, alg-b-results)
  #result
  pass-all-tests
end