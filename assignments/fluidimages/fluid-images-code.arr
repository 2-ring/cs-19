use context essentials2020
include shared-gdrive("fluid-images-definitions.arr", "1D3kQXSwA3yVSvobr_lv7WQIwUZhGCWBp")

provide: liquify-memoization, liquify-dynamic-programming end

include my-gdrive("fluid-images-common.arr")
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE

### imports ###

include string-dict

### general helpers ###

fun is-outside(c :: Coordinate, input :: Image) -> Boolean:
  doc: ```A predicate to determine if the given Coordinate is 
       outside the bounds of the given Image.```
  is-outside-x = (c.x > (input.width - 1)) or (c.x < 0)
  is-outside-y = (c.y > (input.height - 1)) or (c.y < 0)
  is-outside-x or is-outside-y
where:
  is-outside(coord(15, 7), random-10x10) is true
  is-outside(coord(0, 3), cross-3x3) is true
  is-outside(coord(9, 9), random-10x10) is false
  is-outside(coord(5, 7), random-10x10) is false
end

fun color-at(c :: Coordinate, input :: Image) -> Color:
  doc: ```Returns the Color stored at the given Coordinate in the 
       Image. If the Coordinate is out of bounds it returns black.```
  if is-outside(c, input):
    color(0, 0, 0)
  else:
    input.pixels.get((input.height - 1) - c.y).get(c.x)
  end
where:
  color-at(coord(15, 7), random-10x10) is color(0, 0, 0)
  color-at(coord(9, 9), random-10x10) is color(52, 43, 217)
  color-at(coord(5, 7), random-10x10) is color(210, 203, 12)
end
 
fun get-energy(target-coord :: Coordinate, input :: Image) -> Number:
  doc: ```Calculates the 'energy' of the pixel indicated by 
       given Coordinate in the Image. Uses the formula described 
       in the problem handout.```
  #helper
  fun brightness(
      y-dir :: Option<Direction>, 
      x-dir :: Option<Direction>) -> Number: 
    doc: ```Retrieves the brightness value of the pixel adjacent to 
         the current one in the specified direction.```
    neighbour = color-at(target-coord.move(y-dir, x-dir), input)
    cases (Color) neighbour:
      | color(r, g, b) => r + g + b
    end
  end
  #values
  a = brightness(some(up), some(left))
  b = brightness(some(up), none)
  c = brightness(some(up), some(right))
  d = brightness(none, some(left))
  f = brightness(none, some(right))
  g = brightness(some(down), some(left))
  h = brightness(some(down), none)
  i = brightness(some(down), some(right))
  #calculation
  xenergy = ((((a + (2 * d)) + g) - c) - (2 * f)) - i
  yenergy = ((((a + (2 * b)) + c) - g) - (2 * h)) - i
  num-sqrt(num-sqr(xenergy) + num-sqr(yenergy))
where:
  get-energy(coord(1, 1), random-3x3) is-roughly 782.12147
  get-energy(coord(2, 2), random-3x3) is-roughly 1843.6941
  get-energy(coord(9, 9), random-10x10) is-roughly 1830.3071
end

fun calculate-energy(input :: Image) -> StringDict<Number>:
  doc: ```Calculates the 'energy' value for every pixel in the 
       given Image, and returns them as a StringDict. Uses the 
       formula described in the handout.```
    for fold(energy-dict from [string-dict:], row from range(0, input.height)):
      for fold(row-dict from energy-dict, column from range(0, input.width)):
        pixel = coord(column, row)
        pixel-string = to-string(pixel)
        energy = get-energy(coord(column, row), input)
        row-dict.set(pixel-string, energy)
      end
  end
where:
  calculate-energy(one-row) 
    is [string-dict: 
    "coord(0, 0)", 0, 
    "coord(1, 0)", 16, 
    "coord(2, 0)", 0]
  calculate-energy(random-2x2) 
    is-roughly [string-dict:
    "coord(0, 0)", ~1480.979405663698, 
    "coord(1, 0)", ~1363.8423662579191, 
    "coord(0, 1)", ~1744.803713888757, 
    "coord(1, 1)", ~1241.0358576608494]
end

fun top-row(input :: Image) -> List<Coordinate>:
  doc: ```Returns the top row of Coordinates for the given Image.```
  map({(column): coord(column, (input.height - 1))}, range(0, input.width))
where:
  top-row(tied-seams) is [list: 
    coord(0, 2), coord(1, 2), coord(2, 2)]
  top-row(one-row) is [list: 
    coord(0, 0), coord(1, 0), coord(2, 0)]
  top-row(random-2x2) is [list: 
    coord(0, 1), coord(1, 1)]
end
  
fun pick-best(possible-seams :: List<SeamWithCost>) -> SeamWithCost:
  doc: ```Finds the lowest energy Seam out of those in 
       the List provided.```
  cases (List) possible-seams:
    | link(first, rest) =>
      fold({(acc, result): #folding through options
          if result.cost < acc.cost: #finding lowest cost
            result
          else:
            acc
          end}, 
        first, rest)
  end
where:
  pick-best([list:
      seam-with-cost(seam-3x3, 100),
      seam-with-cost(seam-3x10, 88)])
    is seam-with-cost(seam-3x10, 88)
  pick-best([list:
      seam-with-cost(seam-3x3, 100),
      seam-with-cost(seam-3x10, 100)])
    is seam-with-cost(seam-3x3, 100)
end

fun remove-index(index :: Number, lst :: List) -> List:
  doc: ```Removes the value associated with 'index' in the given 
       List. Assumes 'index' is contained within the List.```
  split = lst.split-at(index)
  split.prefix + split.suffix.drop(1)
where:
  remove-index(2, [list: 0, 1, 2, 3, 4, 5]) is [list: 0, 1, 3, 4, 5]
  remove-index(0, [list: "h", "e", "y"]) is [list: "e", "y"]
  remove-index(1, [list: empty, empty, [list: 1]]) is [list: empty, [list: 1]]
end

fun carve-seam(
    seam :: Seam, 
    pixels :: List<List<Color>>) 
  -> List<List<Color>>:
  doc: ```Removes every Coordinate in the given Seam from 'pixels'. 
       Does not make any assumptions about the structure of a Seam.```
  cases (List) seam:
    | empty => pixels
    | link(next-coord, rest-seam) =>
      split = split-at((pixels.length() - 1) - next-coord.y, pixels)
      new-pixels = cases (List) split.suffix:
        | link(to-edit, unedited) =>
          edited = remove-index(next-coord.x, to-edit)
          pre = split.prefix
          split.prefix + [list: edited] + unedited
      end
      carve-seam(rest-seam, new-pixels)
  end
where:
  carve-seam(seam-3x3, random-3x3.pixels) is 
  [list: 
    [list: color(8, 43, 66), color(237, 217, 98)], 
    [list: color(250, 33, 107), color(108, 144, 154)], 
    [list: color(168, 59, 250), color(228, 235, 118)]]
  carve-seam(seam-3x3, cross-3x3.pixels) is 
  [list: 
    [list: color(255, 255, 255), color(255, 255, 255)], 
    [list: color(0, 0, 0), color(0, 0, 0)], 
    [list: color(0, 0, 0), color(255, 255, 255)]]
end

### memoization helpers ###

fun get-seam-memoization(input :: Image) -> Seam:
  doc: ```Finds the lowest-cost Seam in the given Image 
       using memoization```
  memo-table = [mutable-string-dict:]
  energy-map = calculate-energy(input)
  #nested because of memo-table
  fun best-seam-from(pixel :: Coordinate) -> SeamWithCost:
    doc: ```Finds the best Seam from the given pixel to the 
         bottom of the image.```
    pixel-string = to-string(pixel)
    energy = energy-map.get-value(pixel-string)
    memo-value = memo-table.get-now(pixel-string)
    cases (Option) memo-value block:
      | some(best-seam) => best-seam
      | none =>
        pixels-below = [list:
          pixel.move(some(down), some(left)),
          pixel.move(some(down), none),
          pixel.move(some(down), some(right))]
        valid-pixels = filter({(p): not(is-outside(p, input))}, pixels-below)
        result = 
          cases (List) valid-pixels:
            | empty => 
              seam-with-cost([list: pixel], energy)
            | link(_, _) =>       
              possible-seams = map({(p): best-seam-from(p)}, valid-pixels)
              below-result = pick-best(possible-seams)
              best-seam = below-result.seam + [list: pixel]
              seam-cost = below-result.cost + energy
              seam-with-cost(best-seam, seam-cost)
          end
        memo-table.set-now(pixel-string, result)
        result
    end
  end
  #main
  possible-seams = map({(p): best-seam-from(p)}, top-row(input))
  pick-best(possible-seams).seam
where:
  get-seam-memoization(random-3x6) is [list: 
    coord(0, 0), coord(1, 1), coord(1, 2), 
    coord(1, 3), coord(1, 4), coord(1, 5)]
  get-seam-memoization(tied-seams) is [list: 
    coord(1, 0), coord(1, 1), coord(1, 2)]
  get-seam-memoization(random-10x10) is [list: 
    coord(6, 0), coord(7, 1), coord(7, 2), 
    coord(6, 3), coord(5, 4), coord(6, 5), 
    coord(5, 6), coord(6, 7), coord(5, 8), 
    coord(5, 9)]
end

### dynamic helpers ###

fun get-seam-dynamic(input :: Image) -> Seam:
  doc: ```Finds the lowest-cost Seam in the given Image 
       using dynamic programming```
  block:
    energy-map = calculate-energy(input)
    memo-table = [mutable-string-dict:]
    #inserting the base case into the memo-table
    top-seams = map({(pixel):
        block:
          pixel-string = to-string(pixel)
          pixel-energy = energy-map.get-value(pixel-string)
          best-seam = seam-with-cost([list: pixel], pixel-energy)
          memo-table.set-now(pixel-string, best-seam)
          best-seam
        end},
      top-row(input))
    #nested because of memo-table
    fun best-seam-to(pixel :: Coordinate) -> SeamWithCost:
      doc: ```Finds the best Seam from the top of the image 
           to the given pixel.```
      block:
        pixel-string = to-string(pixel)
        #neibours above
        pixels-above = [list:
          pixel.move(some(up), some(left)),
          pixel.move(some(up), none),
          pixel.move(some(up), some(right))]
        #within image bounds
        valid-pixels = filter({(p): not(is-outside(p, input))}, pixels-above)
        #all seams that could be extended from
        possible-seams = map(
          {(p): memo-table.get-value-now(to-string(p))}, 
          valid-pixels)
        best-seam = pick-best(possible-seams)
        extended-seam = best-seam.seam + [list: pixel]
        extended-cost = best-seam.cost + energy-map.get-value(pixel-string)
        result = seam-with-cost(extended-seam, extended-cost)
        #memoizing
        memo-table.set-now(pixel-string, result)
        result
      end
    end
    #extending the base case seams
    extended-seams = 
      for map(y-coord from range(0, input.height - 1).reverse()):
        for map(x-coord from range(0, input.width)):
          best-seam-to(coord(x-coord, y-coord))
        end
      end
    #all possible options
    possible-seams = 
      cases (List) extended-seams:
        | empty => top-seams
        | link(_, _) => extended-seams.last()
      end
    #finding best
    pick-best(possible-seams).seam
  end
where:
  get-seam-dynamic(random-3x6) is [list: 
    coord(1, 5), coord(1, 4), coord(1, 3), 
    coord(1, 2), coord(1, 1), coord(0, 0)]
  get-seam-dynamic(tied-seams) is [list: 
    coord(1, 2), coord(1, 1), coord(1, 0)]
  get-seam-dynamic(random-10x10) is [list: 
    coord(5, 9), coord(5, 8), coord(6, 7), 
    coord(5, 6), coord(6, 5), coord(5, 4), 
    coord(6, 3), coord(7, 2), coord(7, 1), 
    coord(6, 0)]
end

### required functions ###

#tested along with required functions
fun liquify-function(
    get-seam :: (Image, Number -> Seam), 
    input :: Image, 
    n :: Number) -> Image:
  doc: ```Removes the lowest-cost 'n' Seams from the given Image. 
       Uses the provided algorithm to find the Seam to remove.```
  if n <= 0:
    input
  else:
    seam = get-seam(input)
    new-pixels = carve-seam(seam, input.pixels)
    new-image = image-data-to-image(input.width - 1, input.height, new-pixels)
    liquify-memoization(new-image, n - 1)
  end
end

fun liquify-memoization(input :: Image, n :: Number) -> Image:
  doc: ```As described in the problem handout.```
    liquify-function(get-seam-memoization, input, n)
end

fun liquify-dynamic-programming(input :: Image, n :: Number) -> Image:
  doc: ```As described in the problem handout.```
  liquify-function(get-seam-dynamic, input, n)
end

check "Chequerboard pattern.":
  liquify-memoization(chequerboard-8x8, 5)
    is [image(3, 8): 
    color(0, 0, 255), color(0, 0, 255), color(0, 255, 0),
    color(0, 255, 0), color(0, 255, 0), color(0, 0, 255), 
    color(0, 0, 255), color(0, 0, 255), color(0, 255, 0), 
    color(0, 255, 0), color(0, 255, 0), color(0, 0, 255), 
    color(0, 0, 255), color(0, 0, 255), color(0, 255, 0), 
    color(0, 255, 0), color(0, 255, 0), color(0, 0, 255), 
    color(0, 0, 255), color(0, 0, 255), color(0, 255, 0), 
    color(0, 255, 0), color(0, 255, 0), color(0, 0, 255)]
end