use context essentials2020
include shared-gdrive("fluid-images-definitions.arr", "1D3kQXSwA3yVSvobr_lv7WQIwUZhGCWBp")

include my-gdrive("fluid-images-common.arr")
import liquify-memoization, liquify-dynamic-programming
from my-gdrive("fluid-images-code.arr")
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE

### manual tests ###

fun manual-tests(test-function :: (Image, Number -> Image)):
  doc: ```Runs the following suite of tests on the given function.```
  block:
    check "Standard functionality: small image, one seam":
      test-function(random-3x3, 1) 
        is [image(2,3):
        color(152, 225, 127), color(237, 217, 98),
        color(77, 19, 231), color(108, 144, 154),
        color(121, 253, 85), color(228, 235, 118)]
    end 
    check "Standard functionality: big image, several seams":
      test-function(random-10x10, 8)
        is [image(2,10):
        color(99, 78, 189), color(121, 197, 88),
        color(77, 13, 222), color(187, 44, 199), 
        color(200, 123, 222), color(192, 178, 90), 
        color(11, 203, 123), color(111, 23, 211), 
        color(132, 98, 255), color(189, 98, 244), 
        color(67, 155, 255), color(250, 22, 211), 
        color(211, 123, 98), color(255, 11, 122), 
        color(155, 255, 67), color(233, 100, 245), 
        color(200, 188, 245), color(200, 120, 133), 
        color(233, 190, 211), color(190, 100, 255)]
    end 
    check "Standard functionality: tall rectangle, multiple seams":
      liquify-memoization(random-3x6, 2)
        is [image(1, 6): 
        color(46, 83, 244), color(66, 108, 106), color(111, 54, 229), 
        color(58, 193, 33), color(13, 53, 30), color(166, 237, 16)]
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
    check "Resultant image has one column":
      test-function(random-3x3, 2) 
        is [image(1,3):
        color(152, 225, 127),
        color(77, 19, 231),
        color(121, 253, 85)]
    end
    check "Removes correct tied seam":
      test-function(tied-seams, 1) 
        is [image(2,3):
        color(152, 225, 127), color(152, 225, 127), 
        color(250, 33, 107), color(250, 33, 107), 
        color(168, 59, 250), color(168, 59, 250)]
      test-function(tied-seams, 2) 
        is [image(1,3):
        color(152, 225, 127), 
        color(250, 33, 107), 
        color(168, 59, 250)]
    end
    check "One pixel input":
      test-function(one-pixel, 0) is one-pixel
    end  
    check "One row input":
      test-function(one-row, 2) is one-pixel
    end
    check "Remove zero seams":
      test-function(cross-3x3, 0) is cross-3x3
    end  
  end
end

### input generator ###

fun random-color() -> Color:
  doc: "Generates a random Color with RGB values between 0 and 255."
  color(
    num-random(256), 
    num-random(256), 
    num-random(256))
end

fun random-row(width :: Number) -> List<Color>:
  doc: "Generates a random row of Colors for the given width."
  map({(n): random-color()}, range(0, width))
end

fun random-image(width :: Number, height :: Number) -> Image:
  doc: "Generates a random Image of given width and height"
  rows = map({(n): random-row(width)}, range(0, height))
  image-data-to-image(width, height, rows)
end

### random tests ###

fun random-tests(
    algorithm-a :: (Image, Number -> Image),
    algorithm-b :: (Image, Number -> Image)):
  doc: ```Compares the results of two algorithms on a set of randomly 
       generated inputs, and returns if their results always match.```
  block:
    num-test = 30
    max-dimension = 10
    results = map({(_):
        #dimensions
        width = num-random(max-dimension) + 1
        height = num-random(max-dimension) + 1
        #input
        n = num-random(width)
        test-image = random-image(width, height)
        #running algorithms
        result-a = algorithm-a(test-image, n)
        result-b = algorithm-b(test-image, n)        
        #compare
        result-a == result-b}, 
      range(0, num-test))
    fold({(a, b): a and b}, true, results)
  end
end

### main ###

#running both algorithms against a manual test suite
manual-tests(liquify-memoization)
manual-tests(liquify-dynamic-programming)
check "Compare algorithms: 30 randomised tests":
  random-tests(liquify-memoization, liquify-dynamic-programming) is true
end