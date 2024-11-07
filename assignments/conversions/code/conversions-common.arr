use context essentials2021

provide: *, type * end
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE

## data structures ##

data Conversion:
  | conversion(
      from-c :: String, 
      to-c :: String, 
      conv-rate :: Number)
end
type Graph = List<Conversion>

## conversion tables ##

conversion-empty = 
  table: from-c :: String, to-c :: String, conv-rate :: Number end

#|
       (£)
        |
        ↓
        |
       (₫)
|#

one-edge = 
  table: from-c :: String, to-c :: String, conv-rate :: Number
    row: "Pound", "Dong", 32706.52     # GBP to VND
  end

#|
       (£)──>──(₫)
       
       
     (฿)──>──($)

       (¥)──>──(₭)
|#

totally-unconnected = 
  table: from-c :: String, to-c :: String, conv-rate :: Number
    row: "Pound", "Dong", 32706.52 # GBP to VND
    row: "Baht", "Dollar", 0.029    # THB to USD
    row: "Yuan", "Kip", 3042.59    # CNY to LAK
  end

#|
       (£)──>──(₫)
       /    
      ↓ 
     /     
   (฿)     ($)──<>──(¥)
               
            
|#

partially-unconnected = 
  table: from-c :: String, to-c :: String, conv-rate :: Number
    row: "Pound", "Dong", 32706.52 # GBP to VND
    row: "Pound", "Baht", 44.30    # GBP to THB
    row: "Dollar", "Yuan", 7.18    # USD to CNY
    row: "Yuan", "Dollar", 0.14    # +inv
  end

#|
      (£)────
       |     \
       ↓      ↓
       |       \
      (฿)───>────($)
       |         |
       ↓         ↓
       |         |
      (₭)────<───(¥)
                  \   
                   ↓  
                    \
                    (₫)
|#

connected-cyclic = 
  table: from-c :: String, to-c :: String, conv-rate :: Number
    row: "Pound", "Baht", 44.30      # GBP to THB
    row: "Pound", "Dollar", 1.29     # GBP to USD
    row: "Baht", "Dollar", 0.029     # THB to USD
    row: "Dollar", "Yuan", 7.18      # USD to CNY
    row: "Yuan", "Kip", 3042.59     # CNY to LAK
    row: "Yuan", "Dong", 3376        # CNY to VND
    row: "Baht", "Kip", 635.16       # THB to LAK
  end

#|
      (£)────
       |     \
       ↓      X
       |       \
      (฿)───>────($)
       |         |
       X         ↓
       |         |
      (₭)────<───(¥)
                  \   
                   ↓  
                    \
                    (₫)
|#


repeated-still-connected = 
  table: from-c :: String, to-c :: String, conv-rate :: Number
    row: "Pound", "Baht", 44.30      # GBP to THB
    row: "Pound", "Dollar", 1.29     # GBP to USD
    row: "Pound", "Dollar", 1.29     # x2
    row: "Baht", "Dollar", 0.029     # THB to USD
    row: "Dollar", "Yuan", 7.18      # USD to CNY
    row: "Yuan", "Kip", 3042.59      # CNY to LAK
    row: "Yuan", "Dong", 3376        # CNY to VND
    row: "Baht", "Kip", 635.16       # THB to LAK
    row: "Baht", "Kip", 635.16       # x2
  end

#|
      (£)────
       |     \
       ↓      X
       |       \
      (฿)───>────($)
       |         |
       X         X
       |         |
      (₭)────<───(¥)
                  \   
                   ↓  
                    \
                    (₫)
|#

repeated-unconnected = 
  table: from-c :: String, to-c :: String, conv-rate :: Number
    row: "Pound", "Baht", 44.30      # GBP to THB
    row: "Pound", "Dollar", 1.29     # GBP to USD
    row: "Pound", "Dollar", 1.29     # x2
    row: "Baht", "Dollar", 0.029     # THB to USD
    row: "Dollar", "Yuan", 7.18      # USD to CNY
    row: "Dollar", "Yuan", 7.18      # x2
    row: "Yuan", "Kip", 3042.59     # CNY to LAK
    row: "Yuan", "Dong", 3376        # CNY to VND
    row: "Baht", "Kip", 635.16       # THB to LAK
    row: "Baht", "Kip", 635.16       # x2
  end

#|
      (£)────
       |     \
       ↕      ↓
       |       \
      (฿)───<>───($)
       |         |
       ↕         ↓
       |         |
      (₭)────<───(¥)
                  \   
                   ↕  
                    \
                    (₫)
|#

with-inverses = 
  table: from-c :: String, to-c :: String, conv-rate :: Number
    row: "Pound", "Baht", 44.30      # GBP to THB
    row: "Baht", "Pound", 0.023      # +inv
    row: "Pound", "Dollar", 1.29     # GBP to USD
    row: "Baht", "Dollar", 0.029     # THB to USD
    row: "Dollar", "Baht", 34.37     # +inv
    row: "Dollar", "Yuan", 7.18      # USD to CNY
    row: "Yuan", "Kip", 3042.59     # CNY to LAK
    row: "Yuan", "Dong", 3376        # CNY to VND
    row: "Dong", "Yuan", 1/3376      # +inv
    row: "Baht", "Kip", 635.16       # THB to LAK
    row: "Kip", "Baht", 1 / 635.16   # +inv
  end

## art tables ##

art-empty = 
  table: id :: Number, cost :: Number, currency :: String
  end

art-price-zero = table: id :: Number, cost :: Number, currency :: String 
  row: 1, 0, "Dollar"
  row: 2, 0, "Pound"
  row: 3, 0, "Kip"
end

art-unknown-currencies = 
  table: id :: Number, cost :: Number, currency :: String
    row: 7, 3600, "Australian Dollar"
    row: 8, 1500, "Canadian Dollar"
    row: 9, 40, "Jamaican Dollar"
  end

art-all-currencies = 
  table: id :: Number, cost :: Number, currency :: String
    row: 1, 5000, "Pound"
    row: 2, 150000, "Baht"
    row: 3, 2000000, "Dong"
    row: 4, 1000, "Yuan"
    row: 5, 1500, "Dollar"
    row: 6, 200000, "Kip"
    row: 7, 3000, "Pound"
    row: 8, 2500000, "Baht"
    row: 9, 4000, "Dong"
    row: 10, 50000, "Yuan"
    row: 11, 100, "Kip"
  end

art-repeated-ids = 
  table: id :: Number, cost :: Number, currency :: String
    row: 1, 5000, "Pound"
    row: 2, 150000, "Baht"
    row: 2, 2000000, "Dong"
    row: 3, 1000, "Yuan"
    row: 3, 1500, "Dollar"
    row: 3, 200000, "Kip"
    row: 7, 3000, "Pound"
    row: 8, 2500000, "Baht"
    row: 9, 4000, "Dong"
    row: 9, 50000, "Yuan"
    row: 11, 100, "Kip"
  end