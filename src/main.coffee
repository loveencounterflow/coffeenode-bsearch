
############################################################################################################
TYPES 										= require 'coffeenode-types'


#-----------------------------------------------------------------------------------------------------------
@equality = ( data, probe_or_handler ) ->
  return ( @_equality data, probe_or_handler )[ 0 ]

#-----------------------------------------------------------------------------------------------------------
@_equality = ( data, probe_or_handler ) ->
  ### With thx to http://googleresearch.blogspot.de/2006/06/extra-extra-read-all-about-it-nearly.html,
  http://www.dweebd.com/javascript/binary-search-an-array-in-javascript ###
  lo_idx    = 0
  hi_idx    = data.length - 1
  #.........................................................................................................
  if ( TYPES.type_of probe_or_handler ) is 'function'
    handler = probe_or_handler
    h       = handler
  else
    probe   = probe_or_handler
    h       = null
    #.......................................................................................................
    handler = ( value, idx ) =>
      return +1 if probe > value
      return -1 if probe < value
      return  0
  #.........................................................................................................
  while lo_idx <= hi_idx
    mid_idx   = Math.floor ( lo_idx + hi_idx ) / 2
    mid_value = data[ mid_idx ]
    cmp       = handler mid_value, mid_idx
    #.......................................................................................................
    return [ mid_idx, probe, h, ] if cmp == 0
    if cmp < 0 then hi_idx = mid_idx - 1
    else            lo_idx = mid_idx + 1
  #.........................................................................................................
  return [ null, probe, h, ]

#-----------------------------------------------------------------------------------------------------------
@interval = ( data, handler ) ->
  throw new Error "expected a function, got a #{type}" unless ( type = TYPES.type_of handler ) is 'function'
  [ mid_idx
    probe   ] = @_equality data, handler
  return [ mid_idx, mid_idx, ] unless mid_idx?
  #.........................................................................................................
  lo_idx    = mid_idx - 1
  hi_idx    = mid_idx + 1
  last_idx  = data.length - 2
  #.........................................................................................................
  loop
    break if lo_idx - 1 < 0
    break if lo_idx > last_idx
    break if ( handler data[ lo_idx ], lo_idx ) != 0
    lo_idx -= 1
  #.........................................................................................................
  loop
    break if hi_idx - 1 < 0
    break if hi_idx > last_idx
    break if ( handler data[ hi_idx ], hi_idx ) != 0
    hi_idx += 1
  #.........................................................................................................
  return [ lo_idx + 1, hi_idx - 1, ]

#-----------------------------------------------------------------------------------------------------------
@closest = ( data, probe_or_handler ) ->
  lo_idx    = 0
  hi_idx    = data.length - 1
  min_idx   = null
  min_dsta  = +Infinity
  #.........................................................................................................
  if ( TYPES.type_of probe_or_handler ) is 'function'
    handler = probe_or_handler
  else
    probe   = probe_or_handler
    handler = ( value, idx ) =>
      return probe - value
  #.........................................................................................................
  while lo_idx <= hi_idx
    mid_idx   = Math.floor ( lo_idx + hi_idx ) / 2
    mid_value = data[ mid_idx ]
    mid_dst   = handler mid_value, mid_idx
    return mid_idx if mid_dst == 0
    mid_dsta  = Math.abs mid_dst
    #.......................................................................................................
    if min_dsta > mid_dsta
      min_dsta  = mid_dsta
      min_idx   = mid_idx
    #.......................................................................................................
    if mid_dst < 0
      hi_idx = mid_idx - 1
    else
      lo_idx = mid_idx + 1
  #.........................................................................................................
  return min_idx


############################################################################################################
unless module.parent?
  bSearch = @
  # http://oeis.org/A000217: Triangular numbers
  data = [ 0, 1, 3, 6, 10, 15, 21, 28, 36, 45, 55, 66, 78, 91, 105, 120, 136, 153, 171, 190, 210, 231, 253,
    276, 300, 325, 351, 378, 406, 435, 465, 496, 528, 561, 595, 630, 666, 703, 741, 780, 820, 861, 903, 946,
    990, 1035, 1081, 1128, 1176, 1225, 1275, 1326, 1378, 1431 ]
  probe = 300
  delta = 100
  #.........................................................................................................
  compare = ( value ) ->
    return  0 if probe - delta <= value <= probe + delta
    return -1 if probe - delta < value
    return +1
  #.........................................................................................................
  idx = bSearch.equality data, probe
  console.log idx, data[ idx ]
  #.........................................................................................................
  idx = bSearch.equality data, compare
  console.log idx, data[ idx ]
  #.........................................................................................................
  [ lo_idx, hi_idx ] = bSearch.interval data, compare
  console.log [ lo_idx, hi_idx, ], [ data[ lo_idx ], data[ hi_idx ], ]
  #.........................................................................................................
  probe = 300
  idx = bSearch.closest data, probe
  console.log '>>>', probe, idx, data[ idx ]
  #.........................................................................................................
  probe = 1000
  idx = bSearch.closest data, probe
  console.log '>>>', probe, idx, data[ idx ]
  #.........................................................................................................
  probe = 1000
  handler = ( value, idx ) =>
    return value - probe
  idx = bSearch.closest data, probe
  console.log '>>>', probe, idx, data[ idx ]
  #.........................................................................................................
  probe = -120
  idx = bSearch.closest data, probe
  console.log '>>>', probe, idx, data[ idx ]
  #.........................................................................................................
  probe = 4000
  idx = bSearch.closest data, probe
  console.log '>>>', probe, idx, data[ idx ]
  #---------------------------------------------------------------------------------------------------------
  words = """abbatastic abracadabra fellah search canopy catalyst fad jaded alley tajmahal
    supercalifragilisticexpialidocious ferocious pretty horse""".split /\s+/
  matcher = /a/g
  #.........................................................................................................
  get_distance = ( a, b ) ->
    count_a = ( ( a.match matcher ) ? '' ).length
    count_b = ( ( b.match matcher ) ? '' ).length
    return count_a - count_b
  #.........................................................................................................
  match_three_as = ( word ) ->
    return 3 - ( ( word.match matcher ) ? '' ).length
  #.........................................................................................................
  words.sort get_distance
  #.........................................................................................................
  # Find any one word with three `a`s:
  idx = bSearch.equality words, match_three_as
  if idx?
    console.log idx, words[ idx ]
  else
    console.log 'not found'
  #.........................................................................................................
  # Find all words with three `a`s:
  [ lo_idx, hi_idx ] = bSearch.interval words, match_three_as
  if lo_idx?
    console.log [ lo_idx, hi_idx, ]
    console.log ( words[ idx ] for idx in [ lo_idx .. hi_idx ] )
    console.log words[ lo_idx .. hi_idx ]
  else
    console.log 'not found'





