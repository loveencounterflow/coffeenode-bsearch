

- [CoffeeNode bSearch](#coffeenode-bsearch)
	- [`bSearch.equality`](#bsearchequality)
	- [`bSearch.proximity`](#bsearchproximity)
	- [Remarks](#remarks)

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
  # prints `24 300`
  console.log idx, data[ idx ]
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

`bSearch.proximity` builds on bSearch.equality, but instead of returning a single index, it tries to find a
contiguous *range* of matching indices. With the same `data` as in the previous example:

````coffeescript
probe = 300
delta = 100

compare = ( value ) ->
  return  0 if probe - delta <= value <= probe + delta
  return -1 if probe - delta < value
  return +1

[ lo_idx, hi_idx ] = bSearch.proximity data, compare
if lo_idx?
  # prints `[ 20, 27 ] [ 210, 378 ]`
  console.log [ lo_idx, hi_idx, ], [ data[ lo_idx ], data[ hi_idx ], ]
else
  console.log 'not found'
````

The printout tells us that values between `200` and `400` are to be found in postions `20` thru `27` of the
given data.

## Remarks

* When the `data` argument is not sorted in a way that is compliant with the ordering semantics of the
implicit or explicit comparison handler, the behavior of both methods is undefined.

* When you use a comparison handler that returns `0` for a range of values with the `bSearch.equality`
method, the returned index, if any, may point to any 'random' matching value; without knowing the data (and
the  search algorithm), there is no telling which list element will be picked out.


````coffeescript
````

````coffeescript
````



