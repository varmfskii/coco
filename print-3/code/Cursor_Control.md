## PRINT#-3 cursor control

Based on OS-9 VDG control sequences.

^@: null
^A: home, cursor to upper left
^B x y: position cursor, uses x-$20 and y-$20 for position
^C: Erase line (move to beginning of line)
^D: Erase to end of line
^F: cursor right
^H: curstor left (backspace, doesn't erase)
^I: cursor up (yes, this is the usual tab character)
^J: cursor down
^K: clear to end of screen
^L: clear screen (move to home)
^M: carrige return