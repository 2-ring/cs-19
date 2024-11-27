use context essentials2020
include shared-gdrive("fluid-images-definitions.arr", "1D3kQXSwA3yVSvobr_lv7WQIwUZhGCWBp")

provide: *, type * end
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE

### imports ###

include string-dict

### data types ###

data Direction:
  | up
  | down
  | left
  | right
end

#coordinates from bottom left
data Coordinate:
  | coord(x :: Number, y :: Number)
    with:
    method move(
        self,
        y-dir :: Option<Direction>,
        x-dir :: Option<Direction>) -> Coordinate:
      doc: ```Returns the Coordinate shifted by one unit in the
           given direction(s).```
      x-change = ask:
        | x-dir == some(left) then: -1
        | x-dir == none then: 0
        | otherwise: 1
      end
      y-change = ask:
        | y-dir == some(up) then: 1
        | y-dir == none then: 0
        | otherwise: -1
      end
      coord(
        self.x + x-change,
        self.y + y-change)
    end
end

type Seam = List<Coordinate>

data SeamWithCost:
  | seam-with-cost(seam :: Seam, cost :: Number)
end

### urls ###
bangalore-dancers-url = "https://i.ibb.co/HgnyjWF/image.png"
trafalgar-square-url = "https://i.ibb.co/8xR1VnV/trafalgar-square-s2.jpg"

### test seams ###
seam-3x3 = [list: coord(0, 0), coord(0, 1), coord(1, 2)]
seam-3x10 = [list: coord(5, 0), coord(6, 1), coord(7, 2)]

### custom images ###
one-pixel = [image(1,1): color(0, 0, 0)]

one-row = [image(3,1): color(10, 15, 83), color(0, 0, 0), color(4,100,12)]

random-2x2 = [image(2,2):
  color(8, 43, 66), color(152, 225, 127),
  color(77, 19, 231), color(250, 33, 107)]
  
random-3x6 = [image(3, 6): 
  color(46, 83, 244), color(229, 94, 63), color(116, 222, 52), 
  color(197, 190, 49), color(140, 40, 84), color(66, 108, 106),
  color(191, 138, 43), color(253, 16, 186), color(111, 54, 229), 
  color(58, 193, 33), color(241, 239, 153), color(10, 195, 138),
  color(13, 53, 30), color(239, 68, 229), color(162, 234, 52), 
  color(53, 254, 76), color(166, 237, 16), color(229, 255, 198)]

cross-3x3 = [image(3,3):
  color(255, 255, 255), color(0,0,0),  color(255, 255, 255),
  color(0,0,0), color(0,0,0),  color(0,0,0),
  color(255, 255, 255), color(0,0,0),  color(255, 255, 255)]

random-3x3 = [image(3,3):
  color(8, 43, 66), color(152, 225, 127), color(237, 217, 98),
  color(77, 19, 231), color(250, 33, 107), color(108, 144, 154),  
  color(121, 253, 85), color(168, 59, 250), color(228, 235, 118)]

tied-seams = [image(3,3):
  color(152, 225, 127), color(255, 255, 255), color(152, 225, 127),
  color(250, 33, 107), color(255, 255, 255), color(250, 33, 107), 
  color(168, 59, 250), color(255, 255, 255), color(168, 59, 250)]

chequerboard-8x8 = [image(8,8):
  color(0, 0, 255), color(0, 255, 0), color(0, 0, 255), 
  color(0, 255, 0), color(0, 0, 255), color(0, 255, 0), 
  color(0, 0, 255), color(0, 255, 0), color(0, 255, 0), 
  color(0, 0, 255), color(0, 255, 0), color(0, 0, 255), 
  color(0, 255, 0), color(0, 0, 255), color(0, 255, 0), 
  color(0, 0, 255), color(0, 0, 255), color(0, 255, 0), 
  color(0, 0, 255), color(0, 255, 0), color(0, 0, 255), 
  color(0, 255, 0), color(0, 0, 255), color(0, 255, 0),
  color(0, 255, 0), color(0, 0, 255), color(0, 255, 0), 
  color(0, 0, 255), color(0, 255, 0), color(0, 0, 255), 
  color(0, 255, 0), color(0, 0, 255), color(0, 0, 255), 
  color(0, 255, 0), color(0, 0, 255), color(0, 255, 0), 
  color(0, 0, 255), color(0, 255, 0), color(0, 0, 255), 
  color(0, 255, 0), color(0, 255, 0), color(0, 0, 255), 
  color(0, 255, 0), color(0, 0, 255), color(0, 255, 0), 
  color(0, 0, 255), color(0, 255, 0), color(0, 0, 255),
  color(0, 0, 255), color(0, 255, 0), color(0, 0, 255), 
  color(0, 255, 0), color(0, 0, 255), color(0, 255, 0), 
  color(0, 0, 255), color(0, 255, 0), color(0, 255, 0), 
  color(0, 0, 255), color(0, 255, 0), color(0, 0, 255), 
  color(0, 255, 0), color(0, 0, 255), color(0, 255, 0), 
  color(0, 0, 255)]


random-10x10 = [image(10,10):
  color(45, 123, 211), color(233, 189, 94), color(86, 240, 125),
  color(99, 78, 189), color(215, 34, 112), color(63, 98, 144),
  color(190, 235, 122), color(250, 88, 203), color(121, 197, 88),
  color(52, 43, 217), color(77, 13, 222), color(128, 231, 99),
  color(250, 33, 104), color(88, 154, 204), color(90, 190, 111),
  color(210, 33, 55), color(154, 22, 200), color(232, 199, 74),
  color(85, 245, 128), color(187, 44, 199), color(200, 123, 222),
  color(210, 43, 111), color(122, 245, 87), color(223, 89, 154),
  color(88, 190, 204), color(210, 203, 12), color(125, 122, 255),
  color(88, 92, 101), color(221, 102, 54), color(192, 178, 90),
  color(11, 203, 123), color(80, 44, 199), color(33, 250, 78),
  color(211, 122, 89), color(99, 54, 208), color(88, 133, 245),
  color(211, 76, 45), color(167, 200, 78), color(54, 231, 100),
  color(111, 23, 211), color(132, 98, 255), color(33, 245, 188),
  color(245, 67, 89), color(155, 99, 188), color(90, 100, 120),
  color(178, 201, 90), color(245, 88, 121), color(190, 34, 222),
  color(200, 188, 78), color(189, 98, 244), color(67, 155, 255),
  color(133, 205, 11), color(250, 44, 176), color(121, 78, 222),
  color(188, 99, 211), color(199, 122, 245), color(87, 190, 33),
  color(55, 231, 89), color(123, 98, 188), color(250, 22, 211),
  color(211, 123, 98), color(222, 190, 100), color(133, 255, 33),
  color(245, 89, 211), color(111, 44, 88), color(200, 245, 67),
  color(89, 188, 211), color(200, 190, 100), color(211, 133, 245),
  color(255, 11, 122), color(155, 255, 67), color(211, 200, 120),
  color(250, 89, 78), color(122, 88, 190), color(176, 33, 255),
  color(190, 121, 88), color(45, 88, 245), color(122, 255, 190),
  color(188, 78, 123), color(233, 100, 245), color(200, 188, 245),
  color(111, 211, 89), color(88, 190, 255), color(245, 123, 100),
  color(211, 122, 88), color(245, 200, 90), color(78, 233, 122),
  color(99, 255, 176), color(211, 245, 45), color(200, 120, 133),
  color(233, 190, 211), color(245, 200, 88), color(99, 233, 245),
  color(122, 45, 190), color(155, 211, 245), color(245, 176, 122),
  color(245, 67, 88), color(121, 245, 200), color(211, 155, 78),
  color(190, 100, 255)]








