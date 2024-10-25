use context starter2024
#|

   Have fun. And tell us what's neat about it.

   Although certainly not completely original, my program focuses on having fun with the 
   implementation: using a couple things I've been wanting to try, such as: reactors 
   (of course), a somewhat object oriented approach and custom data types. I tried to really 
   take on board some of the concepts learned in class, such as ensuring the function signature
   tells a story and data is clearly pigeon holed. It was for that reason I implemented the data
   types 'Direction' and 'Coordinate' where instead I could have, and in the past probably would
   have, just used a String and a List<Number>. I also tried (more than usual) to streamline the 
   logic as much as possible, which was a fun endeavor. For example, when 'growing' the snake, 
   instead of going to the end of the tail, finding where the tail last was and then adding a new 
   segment to that location, I worked out I could just not shrink the tail according to specific 
   criteria. Finally, I tried to make the game look as good as possible, implementing each 
   aesthetic decision programmatically instead of just importing a photo—e.g. the function 
   'construct-gameboard'.

|#

# imports ##

include image
include reactors

import color as c

## constants ##

#game settings
END-GAME-ON-COLLISION = true
CLOSE-ON-GAME-OVER = false
GAME-SPEED = 0.25

#gameboard constants
#warning: some testing results rely on these default values
SQUARE-LENGTH = 35
BORDER-WIDTH = 0.5 * SQUARE-LENGTH
#must be greater than 10
GAMEBOARD-ROWS = 15
GAMEBOARD-COLUMNS = 17

#images
FOOD-IMAGE = scale(SQUARE-LENGTH / 128, image-url("https://i.ibb.co/sCM9D3c/apple.png"))
SNAKE-COLOR = c.color(70,116,233,255)
HEAD-IMAGE = square(35, "solid", SNAKE-COLOR)
SEGMENT-IMAGE = square(35, "outline", SNAKE-COLOR)

## datatypes ##

data Direction:
  | up
  | down
  | left
  | right
end

data GameState:
  | game-state(
      current-snake :: Snake, 
      score :: Number, 
      food :: Coordinate, 
      game-over :: Boolean)
end

data Coordinate:
  | coord(x :: Number, y :: Number)
end

## classes ##

#tested at bottom
data Snake:
  | snake(
      facing :: Direction, 
      #segments can never be empty
      segments :: List<Coordinate>%(is-link))
sharing: 
  
  method turn(self :: Snake, new-dir :: Direction) -> Snake:
    doc: ```Changes the direction the snake is 'facing', as 
         long as the user is not attempting to turn inwards.```
    cases (List) self.segments:
      | link(head, r) =>
        cases (List) r:
          | link(second, _) =>
            direction-of-body = neighbour-direction(head, second)
            if direction-of-body == new-dir: #can't turn inwards
              self #so no change
            else:
              snake(new-dir, self.segments) #else make change
            end
        end
    end    
  end,   

  method draw-on(self :: Snake, board :: Image) -> Image:
    doc: ```One-by-one overlays each segment on top of the given 
         image 'board', according to the specific coordinates of each segment.```
    coord-of-head = 
      cases (List) self.segments: | link(f, _) => f end

    fun helper(current-segments, current-board) -> Image:
      cases (List) current-segments:
        | empty => current-board
        | link(draw-at, r)=>
          pixel-coord = grid-to-pixel(draw-at)
          image = if (draw-at == coord-of-head): HEAD-IMAGE else: SEGMENT-IMAGE end
          new-board = overlay-xy(
            image, #image to draw
            pixel-coord.x, #where to overlay
            pixel-coord.y, 
            current-board) #image to draw on top of
          helper(r, new-board)
      end
    end

    helper(self.segments, board)
  end,

  method move-head(self :: Snake) -> Coordinate:
    doc: ```Moves the first segment ('head') in the direction the snake is 'facing'.```
    cases (List) self.segments:
      | link(head, _) =>
        cases (Coordinate) head:
          | coord(old-x, old-y) =>
            ask:
              | self.facing == up then: coord(old-x, old-y + 1)
              | self.facing == down then: coord(old-x, old-y - 1)
              | self.facing == left then: coord(old-x - 1, old-y)
              | self.facing == right then: coord(old-x + 1, old-y)
            end
        end
    end
  end,

  method move-tail(self :: Snake, ate :: Boolean) -> List<Coordinate>:
    doc: ```Removes the last segment from the snake unless 
         it 'ate' a food during the current tick, effectivley 
         growing the snake's length by one```
    if ate: 
      self.segments 
    else: 
      omit-last(1, self.segments)
    end
  end,
end

## helper functions ##

fun remove-list<T>(l1 :: List<T>, l2 :: List<T>) -> List<T>:
  doc: ```Removes all instances of every single term in l1 from 
       l2. Neither l1 nor l2 can be empty.```
  cases (List) l1:
    | empty => l2
    | link(f, r) => remove-list(r, remove(l2, f))
  end
where:
  nat-nums-3 = [list: 1, 2, 3]
  ones-5 = [list: 1, 1, 1, 1, 1]
  remove-list([list: 1, 2], nat-nums-3) is [list: 3]
  remove-list(empty, nat-nums-3) is nat-nums-3
  remove-list([list: 1, 1], ones-5) is empty
end

fun coords-in-row(row :: Number) -> List<Coordinate>:
  doc: "Generates a list of all the coordinates contained within a given row."
  fun helper(column):
    if column < GAMEBOARD-COLUMNS:
      link(coord(column, row), helper(column + 1))
    else:
      empty
    end
  end
  helper(0)
where:
  coords-in-row(0) is [list: coord(0, 0), coord(1, 0), coord(2, 0), 
    coord(3, 0), coord(4, 0), coord(5, 0), coord(6, 0), coord(7, 0), 
    coord(8, 0), coord(9, 0), coord(10, 0), coord(11, 0), coord(12, 0), 
    coord(13, 0), coord(14, 0), coord(15, 0), coord(16, 0)]
  coords-in-row(7) is [list: coord(0, 7), coord(1, 7), coord(2, 7), 
    coord(3, 7), coord(4, 7), coord(5, 7), coord(6, 7), coord(7, 7), 
    coord(8, 7), coord(9, 7), coord(10, 7), coord(11, 7), coord(12, 7), 
    coord(13, 7), coord(14, 7), coord(15, 7), coord(16, 7)]
end

fun get-all-coords() -> List<Coordinate>:
  doc: "Generates a list of all the coordinates contained within the game board."
  fun helper(row :: Number):
    if row < GAMEBOARD-ROWS:
      helper(row + 1).append(coords-in-row(row))
    else:
      empty
    end
  end
  helper(0)
where:
  result = get-all-coords()
  #the list of all coordinates is the correct length
  result.length() is GAMEBOARD-ROWS * GAMEBOARD-COLUMNS
  #a few random coordinates appear in the result as expected
  member(result, coord(8, 3)) is true
  member(result, coord(10, 12)) is true
  member(result, coord(1, 3)) is true
end

fun random-empty-coord(full-coords :: List<Coordinate>) -> Coordinate:
  doc: "Finds a coordinate within the game board that is not already full with a snake segment."
  all-coords = get-all-coords()
  possible-coords = remove-list(full-coords, all-coords)
  ran-choice = num-random(possible-coords.length())
  possible-coords.get(ran-choice)
where:
  test-coords = [list: coord(4, 0), coord(5, 0), coord(6, 0), coord(7, 0), coord(8, 0), coord(9, 0)]
  #correct data type
  random-empty-coord(test-coords) satisfies is-coord
  #checks that, after running the function 10 times, none of the results are already full
  fun all-are-empty(n :: Number) -> Boolean:
    if n > 0:
      not(member(test-coords, random-empty-coord(test-coords))) and all-are-empty(n - 1)
    else:
      true
    end
  end
  all-are-empty(10) is true
end
  
fun check-collision(new-segments :: List<Coordinate>):
  doc: ```Checks if the given list of coordinates 'new-segments' represents a 
       collision: either because two coordinates in the list represent the same location
       or because the first coordinate is outside the game board```
  cases (List) new-segments:
    | link(head, tail) =>
      cases (Coordinate) head:
        | coord(head-x, head-y) =>
          hit-tail = member(tail, head)
          hit-wall = 
            ((head-x < 0) or (head-x > (GAMEBOARD-COLUMNS - 1))) #hit a vertical wall
          or ((head-y < 0) or (head-y > (GAMEBOARD-ROWS - 1))) #or a horizontal wall
          hit-tail or hit-wall
      end
  end
where:
  #not collided
  check-collision([list: coord(10, 0), coord(11, 0), coord(12, 0)]) is false
  #almost hit wall
  check-collision([list: coord(2, 14), coord(2, 13), coord(1, 13), coord(1, 12)]) is false
  #hit wall
  check-collision([list: coord(4, 19), coord(3, 19), coord(3, 20)]) is true
  #almost hit tail
  check-collision([list: coord(2, 2), coord(2, 1), coord(1, 1), coord(2, 1)]) is false
  #hit-tail
  check-collision(
    [list: coord(10, 0), coord(10, 1), coord(11, 1), coord(11, 0), coord(10, 0)]) is true
end

fun stick-together(
    alternate-through :: List<Image>, 
    x-times :: Number,
    align :: Direction) -> Image:
  doc: ```Sticks two images together in the direction specified 
       by the parameter 'align'. It does this repeatedly ('x-times') recuring 
       through the images contained within 'alternate-through'. 'alternate-through'
       must contain at least two elements.```
  len = alternate-through.length()

  fun helper(n :: Number):
    if n < x-times:
      current-image = alternate-through.get(num-modulo(n, len))
      ask:
        | is-up(align) then:
          above(helper(n + 1), current-image)
        | is-down(align) then:
          above(current-image, helper(n + 1))
        | is-left(align) then:  
          beside(helper(n + 1), current-image)
        | is-right(align) then:  
          beside(current-image, helper(n + 1))
      end
    else:
      empty-image
    end
  end

  helper(0)
where:
  #only one time
  stick-together([list: SEGMENT-IMAGE, SEGMENT-IMAGE], 1, right) is SEGMENT-IMAGE
  #dimensions respond as expected
  image-width(stick-together([list: SEGMENT-IMAGE, SEGMENT-IMAGE], 4, right)) is (4 * SQUARE-LENGTH)
  image-width(stick-together([list: SEGMENT-IMAGE, SEGMENT-IMAGE], 4, up)) is SQUARE-LENGTH
  image-height(stick-together([list: SEGMENT-IMAGE, SEGMENT-IMAGE], 2, up)) is (2 * SQUARE-LENGTH)
  #correct datatype
  stick-together([list: SEGMENT-IMAGE, SEGMENT-IMAGE], 2, up) satisfies is-image
end

fun omit-last<T>(n :: Number, lst :: List<T>) -> List<T>:
  doc:```Removes the last 'n' terms from 'lst'. 'n' can be no 
      greater than the number of terms in lst.```
  index = lst.length() - n
  split-at(index, lst).prefix
where:
  nat-nums-3 = [list: 1, 2, 3]
  ones-5 = [list: 1, 1, 1, 1, 1]
  #standard
  omit-last(1, nat-nums-3) is [list: 1, 2]
  omit-last(2, nat-nums-3) is [list: 1]
  #empty result
  omit-last(3, nat-nums-3) is empty
  #remove none
  omit-last(0, nat-nums-3) is nat-nums-3
  #repeated elements
  omit-last(4, ones-5) is [list: 1]
end

fun neighbour-direction(c1 :: Coordinate, c2 :: Coordinate) -> Direction:
  doc: ```Returns the direction of c2 in relation to c1, where c1 and c2 and neighbours.```
  {x-diff; y-diff} = 
    cases (Coordinate) c1:
      | coord(c1-x, c1-y) =>
        cases (Coordinate) c2:
          | coord(c2-x, c2-y) =>
            {c1-x - c2-x; c1-y - c2-y}
        end
    end
  ask:
    | y-diff < 0 then: up
    | y-diff > 0 then: down
    | x-diff > 0 then: left
    | x-diff < 0 then: right 
  end
where:
  #all four cardinal directions
  neighbour-direction(coord(8, 9), coord(8, 8)) is down
  neighbour-direction(coord(2, 2), coord(2, 3)) is up
  neighbour-direction(coord(15, 3), coord(14, 3)) is left
  neighbour-direction(coord(0, 0), coord(1, 0)) is right
end

fun grid-to-pixel(grid-coord :: Coordinate) -> Coordinate:
  doc: ```Converts a coordinate from being in terms of the 
       game grid to being in terms of 'overlay-xy' pixel placement.
       Coordinate must be within game board.```
  cases (Coordinate) grid-coord:
    | coord(grid-x, grid-y) =>
      pixel-x = -1 * ((grid-x * SQUARE-LENGTH) + BORDER-WIDTH)
      pixel-y = -1 * ((SQUARE-LENGTH * (GAMEBOARD-ROWS - (grid-y + 1))) + BORDER-WIDTH)
      coord(pixel-x, pixel-y)
  end
where:
  #general functionality
  grid-to-pixel(coord(2, 12)) is coord(-87.5, -87.5)
  grid-to-pixel(coord(3, 1)) is coord(-122.5, -472.5)
  grid-to-pixel(coord(0, 0)) is coord(-17.5, -507.5)
  grid-to-pixel(coord(8, 14)) is coord(-297.5, -17.5)
end

fun construct-gameboard(x :: Number, y :: Number) -> Image:
  doc: ```Creates the backround image for the game according to 
       the grid width and height variables 'x' and 'y'.```
  #different squares
  lighter-sqr = square(SQUARE-LENGTH, "solid", c.color(185,215,89,255))
  darker-sqr = square(SQUARE-LENGTH, "solid", c.color(178,209,82,255))
  #different rows
  row-one = stick-together([list: lighter-sqr, darker-sqr], x, right)
  row-two = stick-together([list: darker-sqr, lighter-sqr], x, right)
  #making them into a board
  chequerboard = stick-together([list: row-one, row-two], y, down)
  border-length = {(num-sqrs): (SQUARE-LENGTH * num-sqrs) + (2 * BORDER-WIDTH)}
  overlay-align("middle", "middle",
    chequerboard, 
    rectangle(border-length(x), border-length(y), "solid", c.color(106,138,57,255)))    
end
GAMEBOARD = construct-gameboard(GAMEBOARD-COLUMNS, GAMEBOARD-ROWS)

## reactor functions ##

fun initializer() -> GameState:
  doc: "Creates the starting GameState."
  starting-x-snake = num-truncate((GAMEBOARD-ROWS + 1) / 3)
  starting-x-food = starting-x-snake * 2
  starting-y = num-truncate((GAMEBOARD-ROWS + 1) / 2)
  initial-segments = [list:
    coord(starting-x-snake, starting-y),
    coord(starting-x-snake - 1, starting-y),
    coord(starting-x-snake - 2, starting-y)]
  initial-snake = snake(right, initial-segments)
  first-food = coord(starting-x-food, starting-y)
  game-state(initial-snake, 0, first-food, false)
end

fun keyboard-input(state :: GameState, key-press :: String) -> GameState:
  doc: "Takes the user's keyboard input and adjusts the GameState accoridingly."
  new-dir-opt = ask:
    | key-press == "up" then: some(up)
    | key-press == "down" then: some(down)
    | key-press == "left" then: some(left)
    | key-press == "right" then: some(right)
    | otherwise: none
  end
  cases (Option) new-dir-opt:
    | none => state
    | some(new-dir) => game-state(state.current-snake.turn(new-dir), 
        state.score, state.food, state.game-over)
  end
end

fun refresh(state :: GameState) -> Image:
  doc: "Converts the values contained with the GameState to an image"
  with-snake = state.current-snake.draw-on(GAMEBOARD)
  food-pos = grid-to-pixel(state.food)
  cases (Coordinate) food-pos: #overlaying the apple too
    | coord(fx, fy) => 
      overlay-xy(FOOD-IMAGE,
        fx, fy, 
        with-snake) 
  end
end

fun update(state :: GameState) -> GameState:
  doc: ```Changes each element according to the fact a new tick 
       has elapsed. Moves the snake as appropriate, then updates the 
       food as a result. Updates if the game is now over.```
  #finds the snakes new position
  s = state.current-snake
  new-head = s.move-head()
  ate = (new-head == state.food) #if the snake is now in the same place as the food 
  new-tail = s.move-tail(ate)
  new-segments = link(new-head, new-tail)
  just-collided = check-collision(new-segments)
  #checks if the game is now over
  won = new-segments.length == (GAMEBOARD-ROWS * GAMEBOARD-COLUMNS)
  game-just-over = won or (just-collided and END-GAME-ON-COLLISION)
  #returns the new gamestate with the necessary changes
  if game-just-over:
    game-state(s, state.score, state.food, true)  #if game is over stop changing anything
  else:
    new-snake = snake(s.facing, new-segments)
    if ate:
      game-state(new-snake, state.score + 1, random-empty-coord(new-segments), false)
    else:
      game-state(new-snake, state.score, state.food, false)
    end
  end
end

fun is-game-over(state :: GameState) -> Boolean:
  doc: ```Checks whether to end the game according to the value of 
  the 'game-over' field of the GameState.```
  state.game-over
end

## reactor ##

game = reactor:
  title: "Snake!!",
  init: initializer(),
  on-tick: update,
  on-key: keyboard-input,
  to-draw: refresh,
  seconds-per-tick: GAME-SPEED,
  stop-when: is-game-over,
  close-when-stop: CLOSE-ON-GAME-OVER
end

## main ##

ending-state = get-value(interact(game))
"Well done!!! What a great game. Your final score was: " 
  + num-to-string(ending-state.score) 
  + "! What a big number."

## testing constants ##

#snakes

crashing-snake = snake(right, 
  [list: coord(10, 1), coord(10, 2), coord(11, 2), coord(11, 1), coord(10, 1)])
snake-up-3 = snake(up, [list: coord(0, 0), coord(1, 0), coord(2, 0)])
snake-down-5 = snake(down, 
  [list: coord(10, 8), coord(10, 9), coord(11, 9), coord(11, 8), coord(10, 8)])

#states  

initial-state = initializer()
finishing-state = game-state(crashing-snake, 2, coord(10, 6), false)
finished-state = game-state(crashing-snake, 2, coord(1, 8), true)
eating-state = game-state(snake-down-5, 2, coord(10, 7), false)

## testing reactor ##

#reactor: initializer

check "initializer: state as expected": 
  initializer()
    is game-state(snake(right, 
      [list: coord(5, 8), coord(4, 8), coord(3, 8)]), 0, coord(10, 8), false)
end

check "initializer: correct data type": 
  initializer() satisfies is-game-state
end

#reactor: keyboard-input

check "keyboard-input: turn as expected":
  keyboard-input(initial-state, "down") 
    is game-state(snake(down, 
      [list: coord(5, 8), coord(4, 8), coord(3, 8)]), 0, coord(10, 8), false)
  keyboard-input(initial-state, "up") 
    is game-state(snake(up, 
      [list: coord(5, 8), coord(4, 8), coord(3, 8)]), 0, coord(10, 8), false)
end

check "keyboard-input: unbound key":
  keyboard-input(initial-state, "tab") 
    is initial-state
  keyboard-input(initial-state, "a") 
    is initial-state
  keyboard-input(initial-state, "9") 
    is initial-state
  keyboard-input(initial-state, "c") 
    is initial-state
end

check "keyboard-input: already in that direction":
  keyboard-input(initial-state, "right") 
    is initial-state
end

check "keyboard-input: doesn't turn inwards":
  keyboard-input(initial-state, "left") 
    is game-state(snake(right, 
      [list: coord(5, 8), coord(4, 8), coord(3, 8)]), 0, coord(10, 8), false)
end

#reactor: refresh

check "refresh: correct data type":
  refresh(initial-state) satisfies is-image
end

check "refresh: image is different once snake moves":
  refresh(update(initial-state)) is-not refresh(initial-state)
end

#reactor: update

check "update: snake moves":
  update(initial-state) is 
  game-state(snake(right, 
      [list: coord(6, 8), coord(5, 8), coord(4, 8)]), 0, coord(10, 8), false)
end

check "update: eats food":
  result = update(eating-state) 
  result.current-snake is snake(down, 
    [list: coord(10, 7), coord(10, 8), coord(10, 9), coord(11, 9), coord(11, 8), coord(10, 8)])
  result.score is 3
end

check "update: game now over":
  result = update(finishing-state)
  result.current-snake is finished-state.current-snake
  result.score is finished-state.score
  result.game-over is finished-state.game-over
end

#reactor: is-game-over

check "is-game-over: no":
  is-game-over(initial-state) is false
end

check "is-game-over: no":
  is-game-over(finished-state) is true
end

## testing snake ##

#snake: turn

check "turn: changes direction":
  snake-up-3.turn(down) is snake(down, [list: coord(0, 0), coord(1, 0), coord(2, 0)])
  snake-down-5.turn(left)
    is snake(left, [list: coord(10, 8), coord(10, 9), coord(11, 9), coord(11, 8), coord(10, 8)])
  snake-down-5.turn(right)
    is snake(right, [list: coord(10, 8), coord(10, 9), coord(11, 9), coord(11, 8), coord(10, 8)])
end

check "turn: stays in same direction":
  snake-up-3.turn(up) is snake(up, [list: coord(0, 0), coord(1, 0), coord(2, 0)])
end

check "turn: doesn't turn inwards":
  snake-down-5.turn(up) is snake-down-5
  snake-up-3.turn(right) is snake-up-3
end

#snake: draw-on

check "refresh: correct data type":
  crashing-snake.draw-on(GAMEBOARD) satisfies is-image
end

#snake: move-head

check "move-head: standard functionality":
  crashing-snake.move-head() is coord(11, 1)
  snake-up-3.move-head() is coord(0, 1)
  snake-down-5.move-head() is coord(10, 7)
end

#snake: move-tail

check "move-tail: has eaten":
  crashing-snake.move-tail(true) 
    is [list: coord(10, 1), coord(10, 2), coord(11, 2), coord(11, 1), coord(10, 1)]
  snake-up-3.move-tail(true)
    is [list: coord(0, 0), coord(1, 0), coord(2, 0)]
  snake-down-5.move-tail(true)
    is [list: coord(10, 8), coord(10, 9), coord(11, 9), coord(11, 8), coord(10, 8)]
end

check "move-tail: hasn't eaten":
  crashing-snake.move-tail(false) is [list: coord(10, 1), coord(10, 2), coord(11, 2), coord(11, 1)]
  snake-up-3.move-tail(false) is [list: coord(0, 0), coord(1, 0)]
  snake-down-5.move-tail(false) is [list: coord(10, 8), coord(10, 9), coord(11, 9), coord(11, 8)]
end