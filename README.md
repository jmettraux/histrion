
# histrion

A character and creature generator.

```
# generate three characters
bin/gen 3

# generate one norse characters
bin/gen norse

# generate two norse characters, don't generate appearance
bin/gen 2 norse -appearance

# generate 6 saxons (but no weaver) and pipe to a2ps for 2 column printing
bin/gen 6 saxon -weaver | a2ps -B --borders=no
```

## license

MIT, see [LICENSE.txt](LICENSE.txt).

