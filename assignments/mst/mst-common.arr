use context essentials2021
include shared-gdrive("mst-definitions.arr", "1BGkPeyFNhp0ND5sENwAXbL-BgQ9ZB_Nt")

provide: *, type * end
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# Write data bindings here that you'll need for tests in 
# both mst-code.arr and mst-tests.arr

## imports ##

include string-dict

## data structures ##

data Element<T>:
  | element(val :: T, ref parent :: Option<Element>)
end

data EdgeHeap:
  | mt
  | node(value :: Edge, left :: EdgeHeap, right :: EdgeHeap)
end

data EltAndHeap:
  | elt-and-heap(elt :: Edge, heap :: EdgeHeap)
end

#|
data Edge:
  | edge(a :: String, b :: String, weight :: Number)
end

type Graph = List<Edge>
|#

## test data ##

#with visualisation

#|
       (X)
        |
        4
        |
       (Y)
|#

letters-graph-2 = [list:
  edge("X", "Y", 4)]

#|
       (A)
       / \
      2   5
     /     \
   (B)--3--(C)
|#

letters-graph-3 = [list:
  edge("A", "B", 2),
  edge("A", "C", 5),
  edge("B", "C", 3)]

#|
       (X)
       |   \
      4|    6
       |     \
      (Y)--2--(W)
       |       |
       7       5
       |       |
      (U)     (Z)

|#

letters-graph-5 = [list:
  edge("X", "Y", 4),
  edge("X", "W", 6),
  edge("Y", "W", 2),
  edge("Z", "W", 5),
  edge("Y", "U", 7)]

#|
      (A)
       |  \
     5 |   10
       |     \
      (B)---3---(C)
       |         |
       2         2
       |         |
      (E)---3---(D)
                  \   
                   1  
                    \
                    (F)
|#

letters-graph-6 = [list:
  edge("A", "B", 5),
  edge("A", "C", 10),
  edge("B", "C", 3),
  edge("C", "D", 8),
  edge("D", "E", 3),
  edge("D", "F", 1),
  edge("B", "E", 2)]

#|
       (P)----
       |      \
      3|       4
       |        \
      (Q)---2---(R)
       |       / |
      5|  --6--  |1
       | /       |
      (S)---4---(T)
       | \     / 
      2|  \1  |3
       |   \  |
      (U)-9--(V)
|#

letters-graph-7 = [list:
  edge("P", "Q", 3),
  edge("P", "R", 4),
  edge("Q", "R", 2),
  edge("Q", "S", 5),
  edge("R", "S", 6),
  edge("R", "T", 1),
  edge("S", "T", 4),
  edge("S", "U", 2),
  edge("S", "V", 1),
  edge("V", "T", 3),
  edge("V", "U", 9)]

#|
       (A)
       / 
      2   
     /     
   (B)     (C)--4--(D)
|#

not-connected-4 = [list:
  edge("A", "B", 2),
  edge("C", "D", 4)]


#|
       (A)--3--(E)
       /    
      2   
     /     
   (B)     (C)--4--(D)
            |       |
            \---3---/
|#

not-connected-5 = [list:
  edge("A", "B", 2),
  edge("C", "D", 4),
  edge("C", "D", 3),
  edge("A", "E", 3)]

#without visualisation

fully-connected-4 = [list:
      edge("A", "B", 5), 
      edge("A", "C", -8),
      edge("A", "D", -3),
      edge("B", "A", 7),
      edge("B", "C", 6),
      edge("B", "D", 4),
      edge("C", "A", -2),
      edge("C", "B", 9),
      edge("C", "D", 5),
      edge("D", "A", 4),
      edge("D", "B", -1),
      edge("D", "C", 7)]
tree-6 = [list: 
      edge("D", "E", 7),
      edge("A", "B", 5), 
      edge("B", "C", 3), 
      edge("B", "E", 2), 
      edge("D", "F", 1)]

## helper functions ##

#general

fun edges-from(target-node :: String, graph :: Graph) -> Graph:
  doc: ```Finds all edges connected to the 'target-node' in the given 'graph'.```
  cases (List) graph:
    | empty => empty 
    | link(current-edge, rest-graph) =>
      cases (Edge) current-edge:
        | edge(u, v, _) =>
          if (u == target-node) or (v == target-node):
            link(current-edge, edges-from(target-node, rest-graph))
          else:
            edges-from(target-node, rest-graph)
          end
      end
  end 
where:
  edges-from("D", letters-graph-6) 
    is [list: edge("C", "D", 8), edge("D", "E", 3), edge("D", "F", 1)]
  edges-from("F", letters-graph-6) 
    is [list: edge("D", "F", 1)]
  edges-from("G", letters-graph-6) 
    is empty
  edges-from("S", letters-graph-7) 
    is [list: 
    edge("Q", "S", 5), 
    edge("R", "S", 6), 
    edge("S", "T", 4), 
    edge("S", "U", 2), 
    edge("S", "V", 1)]
end

fun get-all-nodes(graph :: Graph) -> List<String>:
  doc: ```Returns all nodes contained within the given Graph.```
  distinct(
    fold({(acc, curr):
        cases (Edge) curr:
          | edge(u, v, _) =>
            [list: u, v] + acc
        end}, empty, graph))
where:
  get-all-nodes(letters-graph-6) is [list: "F", "E", "D", "C", "A", "B"]
  get-all-nodes(letters-graph-2) is [list: "X", "Y"]
  get-all-nodes(empty) is empty
  get-all-nodes(not-connected-5) is [list: "E", "C", "D", "A", "B"]
end

fun get-other-node(n :: String, e :: Edge) -> String:
  doc: ```Returns the node contained within edge 'e' 
       other than the given node 'n'.```
  cases (Edge) e:
    | edge(u, v, _) =>
      if u == n:
        v
      else:
        u
      end
  end
where:
  get-other-node("S", edge("S", "T", 4)) is "T"
  get-other-node("T", edge("S", "T", 4)) is "S"
  get-other-node("C", edge("C", "D", 8)) is "D"
  get-other-node("D", edge("D", "F", 1)) is "F"
end

fun random-choice<T>(lst :: List<T>%(is-link)) -> T:
  doc: "Returns a random element within the given non-empty list 'lst'."
  lst.get(num-random(lst.length() - 1))
where:
  test-list = [list: "example", "test", "list"]
  member(test-list, random-choice(test-list)) is true
  random-choice(test-list) satisfies is-string
  random-choice([list: "pick me"]) is "pick me"
end

## union find ##

#https://dcic-world.org/2024-09-03/union-find.html 
#(tweaked from source) - doesn't have to be tested

fun is-in-same-set(e1 :: Element, e2 :: Element) -> Boolean:
  s1 = find-set(e1)
  s2 = find-set(e2)
  identical(s1, s2)
end

fun update-set-with(child :: Element, parent :: Element):
  child!{parent: some(parent)}
end

fun union(e1 :: Element, e2 :: Element):
  s1 = find-set(e1)
  s2 = find-set(e2)
  if identical(s1, s2):
    s1
  else:
    update-set-with(s1, s2)
  end
end

fun find-set(e :: Element) -> Element:
  cases (Option) e!parent block:
    | none => e
    | some(p) =>
      new-parent = find-set(p)
      e!{parent: some(new-parent)}
      new-parent
  end
end

## edge heap ##

#https://tinyurl.com/mst-heaps
#(tweaked from source) - doesn't have to be tested

#heap: new functions

fun edge-max(e1 :: Edge, e2 :: Edge) -> Edge:
  doc: ```Returns the edge with the greatest weight. If they 
       have the same weight returns the first term.```
  cases (Edge) e1:
    | edge(_, _, w1) =>
      cases (Edge) e2:
        | edge(_, _, w2) =>
          ask:
            | w1 > w2 then: e1
            | w1 < w2 then: e2
            | otherwise: e1
          end
      end
  end
where:
  edge-max(edge("A", "B", -112), edge("A", "B", -298)) is edge("A", "B", -112)
  edge-max(edge("A", "B", 0), edge("A", "B", 3)) is edge("A", "B", 3)
  edge-max(edge("X", "Y", 9), edge("A", "B", 9)) is edge("X", "Y", 9)
end

fun edge-min(e1 :: Edge, e2 :: Edge) -> Edge:
  doc: ```Returns the edge with the lesser weight. If they 
       have the same weight returns the second term.```
  cases (Edge) e1:
    | edge(_, _, w1) =>
      cases (Edge) e2:
        | edge(_, _, w2) =>
          ask:
            | w1 > w2 then: e2
            | w1 < w2 then: e1
            | otherwise: e2
          end
      end
  end
where:
  edge-min(edge("A", "B", -112), edge("A", "B", -298)) is edge("A", "B", -298)
  edge-min(edge("A", "B", 0), edge("A", "B", 3)) is edge("A", "B", 0)
  edge-min(edge("X", "Y", 9), edge("A", "B", 9)) is edge("A", "B", 9)
end

fun add-list-to-heap(l :: List, h :: EdgeHeap) -> EdgeHeap:
  doc: ```Inserts every element in 'l' into 'h'.```
  cases (List) l:
    | empty => h
    | link(f, r) => 
      new-h = insert(f, h)
      add-list-to-heap(r, new-h)
  end
where:
  test-heap = node(edge("B", "C", -2), node(edge("A", "B", 5), mt, mt), mt)
  add-list-to-heap([list: edge("D", "A", 0)], test-heap)
    is node(edge("B", "C", -2), node(edge("D", "A", 0), mt, mt), node(edge("A", "B", 5), mt, mt))
  add-list-to-heap([list: edge("B", "C", -2), edge("A", "B", 5)], mt)
    is test-heap
end

#heap: helpers

fun amputate-bottom-left(h :: EdgeHeap%(is-node)) -> EltAndHeap:
  doc: ```Given a EdgeHeap h, produes an EltAndHeap that contains the 
       bottom-left element of h, and h with the bottom-left element removed.```
  cases (EdgeHeap) h:
    | mt => raise("Invalid input: empty heap")
    | node(value, left, right) =>
      cases (EdgeHeap) left:
        | mt => elt-and-heap(value, mt)
        | node(_, _, _) => 
          rec-eltandheap = amputate-bottom-left(left)
          elt-and-heap(rec-eltandheap.elt,
            node(value, rec-eltandheap.heap, right))
      end
  end
end

fun reorder(h :: EdgeHeap) -> EdgeHeap:
  doc: ```Given a EdgeHeap h, where only the top node is misplaced,
       produces a EdgeHeap with the same elements but in proper order.```
  cases(EdgeHeap) h:
    | mt => mt # Do nothing (empty heap)
    | node(val, lh, rh) =>
      cases(EdgeHeap) lh:
        | mt => h # Do nothing (no children)
        | node(lval, llh, lrh) =>
          cases(EdgeHeap) rh:
            | mt => # Just left child
              ask:
                | val.weight < lval.weight then: h # Do nothing
                | otherwise: node(lval, reorder(node(val, llh, lrh)), rh) # Swap left
              end
            | node(rval, rlh, rrh) => # Both children
              ask:
                | (val.weight < lval.weight) and (val.weight < rval.weight) then: 
                  h # Do nothing
                | lval.weight < rval.weight then: 
                  node(lval, reorder(node(val, llh, lrh)), rh) # Swap left
                | lval.weight >= rval.weight then: 
                  node(rval, lh, reorder(node(val, rlh, rrh))) # Swap right
              end
          end
      end
  end
end

fun rebalance(h :: EdgeHeap) -> EdgeHeap:
  doc: ```Given a EdgeHeap h, switches all children along the leftmost path```
  cases (EdgeHeap) h:
    | mt => mt
    | node(val, lh, rh) =>
      node(val, rh, rebalance(lh))
  end
end

#heap: main

fun insert(elt :: Edge, h :: EdgeHeap) -> EdgeHeap:
  doc: ```Takes in a Edge 'elt' and a proper EdgeHeap 'h' produces
       a proper EdgeHeap that has all of the elements of 'h' and 'elt'.```
  cases (EdgeHeap) h:
    | mt => node(elt, mt, mt)
    | node(val, lh, rh) =>
      node(edge-min(elt, val), insert(edge-max(elt, val), rh), lh)
  end
end

fun remove-min(h :: EdgeHeap%(is-node)) -> EdgeHeap:
  doc: ```Given a proper, non-empty EdgeHeap h, removes its minimum element.```
  eltandheap = amputate-bottom-left(h)
  top-replaced = 
    cases (EdgeHeap) eltandheap.heap:
      | mt => mt
      | node(val, lh, rh) =>
        node(eltandheap.elt, lh, rh)
    end
  reorder(rebalance(top-replaced))
end

fun get-min(h :: EdgeHeap%(is-node)) -> Edge:
  doc: ```Takes in a proper, non-empty EdgeHeap h and produces the
       minimum Number in h.```
  cases (EdgeHeap) h:
    | mt => raise("Invalid input: empty heap")
    | node(val,_,_) => val
  end
where:
  get-min(node(edge("1", "5", 9068), node(edge("1", "4", 9400), mt, mt), mt))
end

## required functions ##

## mst-cmp ##

fun get-reachable-nodes(start-node:: String, graph :: Graph) -> List<String>:
  doc: ```Creates a list of nodes reachable in the given Graph from the 'start-node'```
  fun helper(
      todo :: List<String>, 
      seen :: List<String>) 
    -> List<String>:
    cases (List) todo:
      | empty => seen
      | link(current-node, r-todo) =>
        current-edges = edges-from(current-node, graph)
        just-saw = fold(
          {(acc, e): #for each edge connected to current node
            other-node = get-other-node(current-node, e)
            if not(member(seen + acc, other-node)): #if node never seen
              link(other-node, acc) #add it to just-saw
            else:
              acc #otherwise skip
            end}, 
          empty, 
          current-edges)
        new-seen = seen + just-saw
        new-todo = r-todo + just-saw
        helper(new-todo, new-seen)
    end
  end

  helper([list: start-node], [list: start-node])
where:
  get-reachable-nodes("A", letters-graph-3) is [list: "A", "C", "B"]
  get-reachable-nodes("C", not-connected-5) is [list: "C", "D"]
  get-reachable-nodes("E", not-connected-5) is [list: "E", "A", "B"]
end

fun is-connected(graph :: Graph) -> Boolean: 
  doc: ```Determines whether every node in the given Graph is 
       reachable from any other vertex.```
  cases (List) graph:
    | empty => false
    | link(f, r) => 
      cases (Edge) f:
        | edge(start-node, _, _) => 
          reachable-nodes = get-reachable-nodes(start-node, graph)
          all-nodes = get-all-nodes(graph)
          reachable-nodes.length() == all-nodes.length()
      end
  end
where:
  is-connected(letters-graph-3) is true
  letters-graph-2 satisfies is-connected
  letters-graph-3 satisfies is-connected
  letters-graph-5 satisfies is-connected
  letters-graph-6 satisfies is-connected
  letters-graph-7 satisfies is-connected
  not-connected-4 violates is-connected
  not-connected-5 violates is-connected
end