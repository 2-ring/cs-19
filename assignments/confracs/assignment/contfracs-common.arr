use context shared-gdrive("contfracs-context.arr", "1mr5nHB7DDdOffE_hiovBiEuuBsl_59Gh")
include shared-gdrive("contfracs-definitions.arr", "1fFz3TaWdZgIfNxSGVYx0UQz_GXOBIVsc")

provide: *, type * end
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# Write data bindings here that you'll need for tests in both contfracs-code.arr and contfracs-tests.arr

#streams
rec ones = lz-link(1, {(): ones})
rec strings = lz-link("string", {(): strings})
rec emptys = lz-link(empty, {(): emptys})

#streams-opt
rec ones-opt = lz-link(some(1), {(): ones-opt})
rec nones = lz-link(none, {(): nones})


