# movementgame
Godot 4 movement game. It's re-using my old ideas, leveling them up to a systematic way of implementation

# ideas/todos/whatever
need to add two more raycasts at "hand grabs this" level (like the one that goes into the wall for initally positioning the area);
use them when shimmying in order to determine whether to go forward or nay.
ALSO a pair at "hand level" since you know, this kind of a "single object" can happen:

```
    ########
    ########
############
############
############
############
```

imagine being in that top-left corner and trying to go right. the below-hands level raycasts will say "yep, there's an object to be on top of",
while the "hand level" ones will alert us with the "oh no, there's obstrucion for the hands"

also maybe in practical cases of weird curvy stuff it'd be genuinely easier to put the character on a fixed custom curve and in a "yep, this is grabbable" zone instead of all
the raycast trickery. after all I plan on making a rather rectangular city
