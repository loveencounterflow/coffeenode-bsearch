

- [CoffeeNode bSearch](#coffeenode-bsearch)
	- [`bSearch.equality`](#bsearchequality)
	- [`bSearch.proximity`](#bsearchproximity)

> **Table of Contents**  *generated with [DocToc](http://doctoc.herokuapp.com/)*


# CoffeeNode bSearch

CoffeeNode bSearch is a binary search implementation for JavaScript; it includes equality and proximity
search methods.

## `bSearch.equality`

`bSearch.equality` takes a list of sorted values and either a probe value or else a comparison handler as
arguments; on success, it returns the index of the probe (or the value selected by the comparison handler)
within the data or else `null`:

````coffeescript
bSearch = require 'coffeenode-bsearch'
# http://oeis.org/A000217: Triangular numbers
data = [ 0, 1, 3, 6, 10, 15, 21, 28, 36, 45, 55, 66, 78, 91, 105, 120, 136, 153, 171, 190, 210, 231, 253,
  276, 300, 325, 351, 378, 406, 435, 465, 496, 528, 561, 595, 630, 666, 703, 741, 780, 820, 861, 903, 946,
  990, 1035, 1081, 1128, 1176, 1225, 1275, 1326, 1378, 1431 ]

idx = bSearch.equality data, 300
if idx?
  console.log idx, data[ idx ] # prints `24 300`
else
  console.log 'not found'
````

You can do more if you pass in a comparison handler instead of a probe value; the handler should accept
a single value (and possibly the current index) and return `0` where the probe is considered to equal the
value, `-1` when the probe is less than the value, and `+1` otherwise. This is exemplified by the default
handler used internally by `bSearch.equality`:

````coffeescript
handler = ( value, idx ) =>
  return  0 if probe == value
  return -1 if probe <  value
  return +1
````

## `bSearch.proximity`

`bSearch.proximity` builds on `bSearch.equality`; it tries to return a *range* of indices

````coffeescript
````

````coffeescript
````

````coffeescript
````



probe = 300
delta = 100

compare = ( value ) ->
  return  0 if probe - delta <= value <= probe + delta
  return -1 if probe - delta < value
  return +1
