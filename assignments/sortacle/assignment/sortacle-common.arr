use context essentials2021
include shared-gdrive("sortacle-definitions.arr", "1d6n7TSAQa_aTEqLyTXjHxFsdrQAt_lyq")

provide: *, type * end
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# Write data bindings here that you'll need for tests in both sortacle-code.arr and sortacle-tests.arr

fun all-true(bools :: List<Boolean>)
  -> Boolean:
  doc: "determines if all booleans in a list are true"
  fold(lam(acc, bool): acc and bool end, true, bools)
end
