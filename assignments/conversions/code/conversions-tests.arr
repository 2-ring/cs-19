use context essentials2021

include my-gdrive("conversions-common.arr")
import get-art-in-4
from my-gdrive("conversions-code.arr")
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE

#standard functionality
check "non-transitive":
  #direct
  get-art-in-4(art-all-currencies, partially-unconnected, 1, "Baht") 
    is 221500
  #inverse
  get-art-in-4(art-all-currencies, partially-unconnected, 2, "Pound") 
    is 1500000/443
  #both conversion directions
  get-art-in-4(art-all-currencies, partially-unconnected, 4, "Dollar") 
    is 50000/359
end

check "transitive: no inverse":
  get-art-in-4(art-all-currencies, connected-cyclic, 7, "Kip") 
    is 4209794156721/50000
  get-art-in-4(art-all-currencies, connected-cyclic, 7, "Dong") 
    is 11677768836/125
end

check "transitive: with inverse":
  get-art-in-4(art-all-currencies, connected-cyclic, 2, "Pound") 
    is 1500000/443
  get-art-in-4(art-all-currencies, partially-unconnected, 2, "Dong") 
    is 49059780000/443
end

#art errors
check "art not in table":
  get-art-in-4(art-all-currencies, connected-cyclic, 21, "Kip") 
    raises "art-id invalid: missing"
  get-art-in-4(art-repeated-ids, connected-cyclic, 4, "Dollar")
    raises "art-id invalid: missing"
  get-art-in-4(art-empty, connected-cyclic, 1, "Kip")
    raises "art-id invalid: missing"
end

check "art repeated in table":
  get-art-in-4(art-repeated-ids, connected-cyclic, 3, "Dollar") 
    raises "duplicate"
  get-art-in-4(art-repeated-ids, connected-cyclic, 9, "Dollar")
    raises "duplicate"
end

#no path exists
check "no path exists: currency not in table":
  get-art-in-4(art-all-currencies, connected-cyclic, 2, "Afghani") 
    raises "conversion invalid: missing"
  get-art-in-4(art-all-currencies, connected-cyclic, 11, "Dolar")
    raises "conversion invalid: missing"
  get-art-in-4(art-unknown-currencies, partially-unconnected, 9, "Dong")
    raises "conversion invalid: missing"
end

check "no path exists: graph unconnected":
  get-art-in-4(art-all-currencies, partially-unconnected, 4, "Pound")
    raises "conversion invalid: missing"
  get-art-in-4(art-all-currencies, totally-unconnected, 1, "Baht")
    raises "conversion invalid: missing"
end

check "no path exists: because of repeated":
  get-art-in-4(art-all-currencies, repeated-unconnected, 3, "Baht")
    raises "conversion invalid: missing"
  get-art-in-4(art-all-currencies, repeated-unconnected, 1, "Kip")
    raises "conversion invalid: missing"
end

#edge cases
check "already in target currency":
  get-art-in-4(art-all-currencies, totally-unconnected, 6, "Kip") 
    is 200000
  get-art-in-4(art-all-currencies, one-edge, 9, "Dong") 
    is 4000
end

check "art pirce is zero":
  get-art-in-4(art-price-zero, totally-unconnected, 1, "Baht") is 0
end

check "multiple valid paths and graph has cycles":
  get-art-in-4(art-all-currencies, connected-cyclic, 1, "Dong")
    is 3892589612/25
  get-art-in-4(art-all-currencies, connected-cyclic, 11, "Dollar")
    is 500000/109228981
end

check "repeated edges: repeated-still-connected":
  get-art-in-4(art-all-currencies, repeated-still-connected, 8, "Dong")
    is 1757376800
  get-art-in-4(art-all-currencies, repeated-still-connected, 10, "Pound")
    is 25000000000/4612073
end






