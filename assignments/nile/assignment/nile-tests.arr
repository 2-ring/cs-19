use context essentials2021
include shared-gdrive("nile-definitions.arr", "1G0l8Il4LBoenLdJ6tfu4grP4vGouMN6M")

include my-gdrive("nile-common.arr")
import recommend, recommend-in-ok, recommend-out-ok,
       popular-pairs, popular-pairs-in-ok, popular-pairs-out-ok
from my-gdrive("nile-code.arr")
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# Write your examples and tests in here. These should not be tests of implementation-specific details (e.g., helper functions).


#recommend

check "standard functionality":
  recommend("T_1",
    [list:
      f-3,
      f-3,
      f-3-v2])
    is recommendation(2, [list: "T_2", "T_3"])
  recommend("T_1",
    [list:
      f-2,
      f-3,
      f-3,
      f-3-v2]) 
    is recommendation(3, [list: "T_2"])
end

check "no pairs":
  recommend("??",
    [list:
      f-3,
      f-3,
      f-3-v2])
    is recommendation(0, [list:])
end

check "empty book records":
  recommend("??",
    [list:])
    is recommendation(0, [list:])
end

check "special charecters":
  recommend("&^&(*)(*!11>>.2",
    [list: file("r0872..2/~][2", [list: "cie873{;.e3';q32012", "HJBD23p4.''p';/'[9]"])])
    is recommendation(0, [list: ])
end

#popular-pairs tests
  
check "standard functionality":
  popular-pairs([list:
      f-3,
      f-3-v2,
      f-3-v2])
    is recommendation(2, 
    [list: pair("A_1", "A_2"), pair("A_1", "A_3"), pair("A_2", "A_3")])
  popular-pairs([list:
      f-2,
      f-3,
      f-3-v2,
      f-3-v2])
    is recommendation(2, 
    [list: pair("A_1", "A_2"), pair("A_1", "A_3"), pair("A_2", "A_3"), pair("T_1", "T_2")])
  popular-pairs([list:
      f-2,
      f-3,
      f-3,
      f-3-v2])
    is recommendation(3, 
    [list: pair("T_1", "T_2")])
end

check "only one pair":
  popular-pairs([list:
      f-2])
    is recommendation(1, 
    [list: pair("T_1", "T_2")])
end

check "lots of the same":
  popular-pairs([list:
    f-3,
    f-3,
    f-3,
    f-3,
    f-3])
    is recommendation(5, 
    [list: pair("T_1", "T_2"), pair("T_1", "T_3"), pair("T_2", "T_3")])
end

check "empty book records":
  recommend("??",
    [list:])
    is recommendation(0, [list:])
end