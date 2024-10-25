use context essentials2021

include my-gdrive("tables-common.arr")
import get-art-in-1, get-art-in-2, get-art-in-3
  from my-gdrive("tables-code.arr")
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# Write your examples and tests in here. These should not be tests of implementation-specific details (e.g., helper functions).

#art tables
a-normal = table: id :: Number, cost :: Number, currency :: String
  row: 1, 100, "Dollars" 
  row: 2, 55, "Pounds" 
  row: 3, 8, "Dollars" 
  row: 4, 30, "Euros" 
  row: 5, 349, "Baht" 
  row: 6, 999, "Bolivianos" 
  row: 7, 1, "Pounds" 
  row: 8, 780, "Dollars"
end

a-normal-2 = table: id :: Number, cost :: Number, currency :: String
  row: 3, 8, "Dollars" 
  row: 4, 30, "Euros" 
  row: 5, 349, "Baht" 
  row: 6, 999, "Bolivianos" 
  row: 7, 1, "Pounds"
end

a-repeated-x2 = table: id :: Number, cost :: Number, currency :: String
  row: 1, 100, "Dollars" 
  row: 2, 55, "Pounds" 
  row: 3, 8, "Dollars" 
  row: 1, 100, "Dollars"
end

a-repeated-x3 = table: id :: Number, cost :: Number, currency :: String 
  row: 1, 100, "Dollars" 
  row: 3, 8, "Dollars"
  row: 2, 55, "Pounds" 
  row: 3, 8, "Dollars"
  row: 3, 8, "Dollars"
end

a-empty = table: id :: Number, cost :: Number, currency :: String 
end

a-one-element = table: id :: Number, cost :: Number, currency :: String 
row: 1, 100, "Dollars"
end

#conversion tables

c-normal = table: from-c :: String, to-c :: String, conv-rate :: Number 
  row: "Dollars", "Pounds", 0.75
  row: "Pounds", "Baht", 44
  row: "Riel", "Australian Dollar", 0.00036
end

c-inverse =  table: from-c :: String, to-c :: String, conv-rate :: Number 
  row: "Pounds", "Dollars", 1.2
  row: "Baht", "Pounds", 0.02
  row: "Australian Dollar", "Riel", 2700
end

c-one-element = table: from-c :: String, to-c :: String, conv-rate :: Number
  row: "Dollars", "Pounds", 0.75
end

#get-art-in-1

check "normal functionality":
  get-art-in-1(a-normal, c-normal, 7, "Baht") is 44
  get-art-in-1(a-normal, c-normal, 3, "Pounds") is 6
  get-art-in-1(a-normal, c-one-element, 1, "Pounds") is 75
end

check "already correct":
  get-art-in-1(a-normal, c-normal, 6, "Bolivianos") is 999
  get-art-in-1(a-normal, c-normal, 8, "Dollars") is 780
end

#get-art-in-2

check "normal functionality":
  get-art-in-2(a-normal, c-normal, 7, "Baht") is 44
  get-art-in-2(a-normal, c-normal, 3, "Pounds") is 6
  get-art-in-2(a-normal, c-one-element, 1, "Pounds") is 75
end

check "already correct":
  get-art-in-2(a-normal, c-normal, 6, "Bolivianos") is 999
  get-art-in-2(a-normal, c-normal, 8, "Dollars") is 780
end

check "missing art":
  get-art-in-2(a-normal-2, c-normal, 2, "Baht")
    raises "art-id invalid: missing"
  get-art-in-2(a-normal, c-normal, 10, "Pounds")
    raises "art-id invalid: missing"
  get-art-in-2(a-empty, c-normal, 3, "Pounds")
    raises "art-id invalid: missing"
end

check "repeated art":
  get-art-in-2(a-repeated-x2, c-normal, 1, "Bolivianos") 
    raises "art-id invalid: duplicate"
  get-art-in-2(a-repeated-x3, c-normal, 3, "Dollars") 
    raises "art-id invalid: duplicate"
end

check "missing conversion":
  get-art-in-2(a-normal, c-normal, 4, "Pesos")
    raises "conversion invalid: missing"
  get-art-in-2(a-normal, c-normal, 4, "Pounds")
    raises "conversion invalid: missing"
end

check "conversion wrong way":
  get-art-in-2(a-normal, c-normal, 2, "Dollars") 
    raises "conversion invalid: missing"
end

check "repeated conversion":
  get-art-in-2(a-repeated-x2, c-normal, 1, "Bolivianos") 
    raises "art-id invalid: duplicate"
  get-art-in-2(a-repeated-x3, c-normal, 3, "Dollars") 
    raises "art-id invalid: duplicate"
end

#get-art-in-3

check "normal functionality":
  get-art-in-3(a-normal, c-normal, 7, "Baht") is 44
  get-art-in-3(a-normal, c-normal, 3, "Pounds") is 6
  get-art-in-3(a-normal, c-one-element, 1, "Pounds") is 75
end

check "already correct":
  get-art-in-3(a-normal, c-normal, 6, "Bolivianos") is 999
  get-art-in-3(a-normal, c-normal, 8, "Dollars") is 780
end

check "missing art":
  get-art-in-3(a-normal-2, c-normal, 2, "Baht")
    raises "art-id invalid: missing"
  get-art-in-3(a-normal, c-normal, 10, "Pounds")
    raises "art-id invalid: missing"
  get-art-in-3(a-empty, c-normal, 3, "Pounds")
    raises "art-id invalid: missing"
end

check "repeated art":
  get-art-in-3(a-repeated-x2, c-normal, 1, "Bolivianos") 
    raises "art-id invalid: duplicate"
  get-art-in-3(a-repeated-x3, c-normal, 3, "Dollars") 
    raises "art-id invalid: duplicate"
end

check "conversion wrong way":
  get-art-in-3(a-normal, c-inverse, 7, "Baht") is 50
  get-art-in-3(a-normal, c-inverse, 3, "Pounds") is 20/3
  get-art-in-3(a-normal, c-inverse, 1, "Pounds") is 250/3
end

check "repeated conversion":
  get-art-in-3(a-repeated-x2, c-normal, 1, "Bolivianos") 
    raises "art-id invalid: duplicate"
  get-art-in-3(a-repeated-x3, c-normal, 3, "Dollars") 
    raises "art-id invalid: duplicate"
end