use context essentials2021
include shared-gdrive("nile-definitions.arr", "1G0l8Il4LBoenLdJ6tfu4grP4vGouMN6M")

provide: *, type * end
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# Write data bindings here that you'll need for tests in both nile-code.arr and nile-tests.arr

#files for testing
f-2 = file("f-2.txt", [list: "T_1", "T_2"])
f-2-v2 = file("f-2-v2.txt", [list: "A_1", "A_2"])
f-3 = file("f-3.txt", [list: "T_1", "T_2", "T_3"])
f-3-v2 = file("f-3-v2.txt", [list: "A_1", "A_2", "A_3"])

one-book = file("1_book.txt", [list: "T_1"])

special-chars = file("special_chars.txt", [list: "((*&:@{:", "!!11__AA!", "|//@#!/|"])

