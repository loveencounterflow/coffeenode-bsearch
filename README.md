

- [CoffeeNode bSearch](#coffeenode-bsearch)
	- [Why?](#why)
	- [`bSearch.equality`](#bsearchequality)
	- [`bSearch.interval`](#bsearchinterval)
	- [`bSearch.closest`](#bsearchclosest)
	- [Examples with Custom Distance Function](#examples-with-custom-distance-function)
		- [Nonsensical Letter-Counting](#nonsensical-letter-counting)
		- [A More Realistic Example Using Dates](#a-more-realistic-example-using-dates)
	- [Remarks](#remarks)
	- [Caveats](#caveats)
	- [Future](#future)

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

There are three methods exported by this module; in order of ascending generality (yes, you can do a
mental binary search to locate the method that best fits your use case ;-):

* [**Equality Search**](#bsearchequality) will return the index of a data list argument that *equals* the
probe search for, or `null` if no element matches;

* [**Interval Search**](#bsearchinterval) which will return a possibly empty list of indices with those
elements of the data list that lie *within a given distance* form a certain probe; and

* [**Proximity Search**](#bsearchclosest) which will return the index of that element that lies *closest*
to a given probe.

It is possible to use your own comparison functions with these methods, so distance and ordering metrics
are in no way confined to the canonical example (i.e. locating a match in an ordered list of numbers which
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
idx   = bSearch.closest data, probe
if idx?
  # prints `44 990`
  console.log idx, data[ idx ]
else
  console.log 'not found'
````

The second argument to `bSearch.closest` may be a distance function similar to the one shown here or else
a probe value; in the latter case, the default distance function shown above will be used.

## Examples with Custom Distance Function

### Nonsensical Letter-Counting

To convey a taste of the generality afforded by custom distance functions, we here present in all briefness
a pretty nonsensical example which involves finding words with a given number of `a`s in them. Unlikely
you'll ever want to do that in the real world, but you get the idea.

Setup:

````coffeescript
words = """abbatastic abracadabra fellah search canopy catalyst fad jaded alley tajmahal
  supercalifragilisticexpialidocious ferocious pretty horse""".split /\s+/
matcher = /a/g

sorter = ( a, b ) ->
  count_a = ( ( a.match matcher ) ? '' ).length
  count_b = ( ( b.match matcher ) ? '' ).length
  return count_a - count_b

match_three_as = ( word ) ->
  return 3 - ( ( word.match matcher ) ? '' ).length

words.sort sorter
````

Usage:

````coffeescript
# Find any one word with three `a`s:
idx = bSearch.equality words, match_three_as
if idx?
  console.log idx, words[ idx ]
else
  console.log 'not found'
````

This should print

````coffeescript
10 'tajmahal'
````

Note that the result is not complete as there are more words with three `a`s. We account for that with
`bSearch.interval`:

````coffeescript
# Find all words with three `a`s:
[ lo_idx, hi_idx ] = bSearch.interval words, match_three_as
if lo_idx?
  console.log [ lo_idx, hi_idx, ]
  console.log words[ lo_idx .. hi_idx ]
else
  console.log 'not found'
````

This should print

````coffeescript
[ 10, 12 ]
[ 'tajmahal',
  'supercalifragilisticexpialidocious',
  'abbatastic' ]
````

### A More Realistic Example Using Dates

Since JavaScript Date objects are coerced to numbers whenever they are used with the `+` and `-` operators
which are used by the default distance functions in CoffeeNode bSearch, it's straightforward to find the
closest point in time out of an ordered list of dates:

````coffeescript
  high_and_low_water_times = [
    new Date '2014-12-27T00:51'
    new Date '2014-12-27T07:12'
    new Date '2014-12-27T13:20'
    new Date '2014-12-27T19:46'
    new Date '2014-12-28T01:45'
    new Date '2014-12-28T08:06'
    new Date '2014-12-28T14:16'
    new Date '2014-12-28T20:40'
    new Date '2014-12-29T02:41'
    new Date '2014-12-29T08:58'
    new Date '2014-12-29T15:10'
    new Date '2014-12-29T21:38'
    new Date '2014-12-30T03:35'
    new Date '2014-12-30T10:02'
    new Date '2014-12-30T16:09'
    new Date '2014-12-30T22:45'
    ]

  first_quarter = new Date '2014-12-28T19:31'
  idx = bSearch.closest high_and_low_water_times, first_quarter

  console.log 'first quarter:                     ', first_quarter
  console.log()
  console.log 'closest tidal event:               ', high_and_low_water_times[ idx ]
  console.log()

  milliseconds  =    1
  seconds       = 1000 * milliseconds
  minutes       =   60 * seconds
  hours         =   60 * minutes
  twelve_hours  =   12 * hours

  [ lo_idx, hi_idx ] = bSearch.interval high_and_low_water_times, ( value ) ->
    dt = first_quarter - value
    return  0 if  ( Math.abs dt ) <= twelve_hours
    return +1 if  dt > 0
    return -1

  for idx in [ lo_idx .. hi_idx ]
    console.log 'tidal event closer than twelve hours: ', high_and_low_water_times[ idx ]
````
This will print out:
````
first quarter:                          Sun Dec 28 2014 20:31:00 GMT+0100 (CET)

closest tidal event:                    Sun Dec 28 2014 21:40:00 GMT+0100 (CET)

tidal event closer than twelve hours:   Sun Dec 28 2014 09:06:00 GMT+0100 (CET)
tidal event closer than twelve hours:   Sun Dec 28 2014 15:16:00 GMT+0100 (CET)
tidal event closer than twelve hours:   Sun Dec 28 2014 21:40:00 GMT+0100 (CET)
tidal event closer than twelve hours:   Mon Dec 29 2014 03:41:00 GMT+0100 (CET)
````

> **Caveat** Do not try to sort a list of JavaScript Date objects using the standard `Array::sort` method—it
> will sort list elements other than numbers using each value's `toString` method and fail in subtle ways if
> the list should contain changes from daylight saving time to winter time, as shown by this short snippet
> (which works on machines localized to Germany and may behave differently on machines running in a
> different locale):
> ````coffeescript
> dates = [
>   new Date '2014-10-26T00:59'
>   new Date '2014-10-26T01:00' ]
>
> console.log dates
> console.log dates.sort()
> ````
> Output:
> ````coffeescript
> [ Sun Oct 26 2014 02:59:00 GMT+0200 (CEST),
>   Sun Oct 26 2014 02:00:00 GMT+0100 (CET) ]
> [ Sun Oct 26 2014 02:00:00 GMT+0100 (CET),
>   Sun Oct 26 2014 02:59:00 GMT+0200 (CEST) ]
> ````
> We can clearly see how JavaScript does the *right* thing when trying to come to grips with the DST switch
> (which means clocks will switch from `02:59` (sometimes labelled `02:59a`) 'back' to `02:00` (sometimes
> labelled `02:00b`)), but does the *wrong* thing when trying to sort the dates.


## Remarks

* When the `data` argument is not sorted in a way that is compliant with the ordering semantics of the
implicit or explicit comparison handler, the behavior of all three methods is undefined.

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

* Be aware that bSearch always uses JavaScript's strict
equality operator unless you pass in a comparison function. Strict equality comparisons
[have their limitations](http://bonsaiden.github.io/JavaScript-Garden/#types.equality) and are generally
not to be used when comparing anything but numbers or else texts that are sorted according to Unicode
character values.

## Caveats

This module has no test suite as yet, so its correctness and performance are more of a conjecture than a
proven fact. Also, we do presently no memoizing of comparison results which may or may not lead to
sub-optimal performance; since the implementation is intended to be completely agnostic as for the nature
of the searched data, caching is hardly to be implemented easily and correctly for the general case.

> If indeed your comparison (or distance) function does rely on lengthy calculations, consider to implement
> a memoizing functionality that fits your use case.

## Future

It should not be too difficult to extend the API to accept minimum and maximum indices; that way, splicing
several long list of sorted, commensurable data could be sped up.


