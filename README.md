

- [CoffeeNode bSearch](#coffeenode-bsearch)
	- [Why?](#why)
	- [`bSearch.equality`](#bsearchequality)
	- [`bSearch.interval`](#bsearchinterval)
	- [`bSearch.closest`](#bsearchclosest)
	- [Remarks](#remarks)
	- [Caveats](#caveats)

> **Table of Contents**  *generated with [DocToc](http://doctoc.herokuapp.com/)*


# CoffeeNode bSearch

CoffeeNode bSearch is a binary search implementation for JavaScript; it includes equality and proximity
search methods. Say `npm install coffeenode-bsearch` and start searching faster today!

## Why?

Binary search is a valuable tool to quickly locate items in sorted collections. Although anyone who has
ever used a dictionary or a telephone directory to locate some piece of information has naturally employed
an informal version of binary search, sadly this important algorithm is not too frequently implemented correctly;
as [one writer put it](http://googleresearch.blogspot.de/2006/06/extra-extra-read-all-about-it-nearly.html),
"Nearly All Binary Searches and Mergesorts are broken" (notwithstanding, it may very well be that the
module presented here has its flaws and bugs; feel free to report issues). Assuming a correct
implementation, binary search will do at most ⌊log<sub>2</sub>(*N*)+1⌋ comparisons, which means that when
you otherwise had to look at up to a million values with a linear search, you'll get away with twenty
comparisons when doing binary search.

Another reason to publish yet another module for binary search is the scarcity of turn-key solutions that
**(1)** incorporate the most obvious and useful generalizations of binary search, and **(2)** do not rely
on special data structures like balanced trees (which most of the time you'd have to build before you can
search; given that the entire motivation for doing a binary search instead of a linear search is the sheer
amount of data to be searched, this can lead to significant overhead. I'm not a particular fan of algorithms
that force you to build a non-general data structure upfront that you'll then maybe only use once before
throwing it away).

There are three methods exported by this module; in order of ascending generality:

* **Equality Search** will return the index of a data list argument that *equals* the probe search for, or
`null` if no element matches;

* **Interval Search** which will return a possibly empty list of indices with those elements of the data
list that lie *within a given distance* form a certain probe; and

* **Proximity Search** which will return the index of that element that lies *closest* to a given probe.

It is possible to use your own comparison methods with these methods, so distance and ordering metrics
are in no way confined to the canonical example (i.e. locating a match in an ordered list of numbered which
are tested with the `<`, `==`, and `>` operators).


## `bSearch.equality`

`bSearch.equality` takes a list of sorted values (in ascending order) and either a probe value or else a
comparison handler as arguments; on success, it returns the index of the probe (or the value selected by the
comparison handler) within the data or else `null`:

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

## `bSearch.interval`

`bSearch.interval` builds on `bSearch.equality`, but instead of returning a single index, it tries to find
a contiguous *range* of matching indices. With the same `data` as in the previous example:

````coffeescript
probe = 300
delta = 100

compare = ( value ) ->
  return  0 if probe - delta <= value <= probe + delta
  return -1 if probe - delta < value
  return +1

[ lo_idx, hi_idx ] = bSearch.interval data, compare
if lo_idx?
  # prints `[ 20, 27 ] [ 210, 378 ]`
  console.log [ lo_idx, hi_idx, ], [ data[ lo_idx ], data[ hi_idx ], ]
else
  console.log 'not found'
````

The printout tells us that values between `200` and `400` are to be found in positions `20` thru `27` of the
given data.

## `bSearch.closest`

`bSearch.closest` works like `bSearch.equality`, except that it always returns a non-null index for a
non-empty data list, and that the result will point to (one of) the closest neighbors to the probe or
distance function passed in. With the same `data` as in the previous examples:

````coffeescript
handler = ( value, idx ) =>
  return probe - value
probe = 1000
idx   = BS.closest data, probe
if idx?
  # prints `44 990`
  console.log idx, data[ idx ]
else
  console.log 'not found'
````

The second argument to `bSearch.closest` may be a distance function similar to the one shown here or else
a probe value; in the latter case, the default distance function shown above will be used.

## Remarks

* When the `data` argument is not sorted in a way that is compliant with the ordering semantics of the
implicit or explicit comparison handler, the behavior of both methods is undefined.

> With 'ordering semantics' we here simple mean that when run across the entire data list, the values
> *d*<sub>*i*</sub> returned by the comparison function must always obey
> *d*<sub>*i*</sub> <= *d*<sub>*j*</sub> when *i* <= *j*.
> As such, you *can* have a data list of numerically *descending* values
> as long as your handler returns a series of *non-descending* comparison metrics when iterating over the list.

* When you use a comparison handler that returns `0` for a range of values with the `bSearch.equality`
method, the returned index, if any, may point to any 'random' matching value; without  knowing the data (and
the search algorithm), there is no telling which list element will be picked out.

* Likewise, when using a distance function that returns the same minimum distance for more than a single
value with the `bSearch.closest` method, the returned index, if any, may point to any 'random' matching
value.

## Caveats

This module has no test suite as yet, so its correctness and performance are more of a conjecture than a
proven fact. Also, we do presently no memoizing of comparison results which may or may not lead to
sub-optimal performance; since the implementation is intended to be completely agnostic as for the nature
of the searched data, caching is hardly to be implemented easily and correctly for the general case.

> If indeed your comparison (or distance) function does rely on lengthy calculations, consider to implement
> a memoizing functionality that fits your use case.





