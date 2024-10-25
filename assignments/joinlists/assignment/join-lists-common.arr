use context essentials2021
include shared-gdrive("join-lists-definitions.arr", "1gNl8Rt88uWqpbv0Hx9Fkh6ajnNoDr164")

provide: *, type * end
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# Write data bindings here that you'll need for tests in both join-lists-code.arr
# and join-lists-tests.arr

#general testing constants

natural-nums-3 = [join-list: 1, 2, 3]
natural-nums-7 = [join-list: 1, 2, 3, 4, 5, 6, 7]
random-nums-5 = [join-list: 101, 73, 55, 10, 11]

random-bools-4 = [join-list: true, false, false, false]
random-lists-2 = [join-list: [list: 5, 3, 1, 10], [list: 19]]
random-strings-3 = [join-list: "Descend", "to", "EARTH!!"]

one-term-num = [join-list: 8743]
one-term-string = [join-list: "Greetings Little One"]

#sort testing constants

strings-some-same-len = [join-list: "123", "321", "1", "12", "345", ""]
strings-all-same-len = [join-list: "ben", "sam", "ned", "tom"]
sorted-by-squares = [join-list: -71, -52, 10, 4, -3, -1, 0]
sorted-by-first = [join-list: [list: 6, 100], [list: 5, 1, 4], [list: 1, 99]]
sorted-by-length = [join-list: [list: 6], [list: 5], [list: 1, 99]]
