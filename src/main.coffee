



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
    handler = ( value, probe, idx ) =>
      return  0 if probe == value
      return -1 if probe <  value
      return +1
  #.........................................................................................................
  while lo_idx <= hi_idx
    mid_idx   = Math.floor ( lo_idx + hi_idx ) / 2
    mid_value = data[ mid_idx ]
    lo_value  = data[  lo_idx ]
    hi_value  = data[  hi_idx ]
    cmp       = handler mid_value, probe, mid_idx
    #.......................................................................................................
    if cmp == 0
      return [ mid_idx, probe, h, ]
    else if cmp < 0
      hi_idx = mid_idx - 1
    else
      lo_idx = mid_idx + 1
  #.........................................................................................................
  return [ null, probe, h, ]

#-----------------------------------------------------------------------------------------------------------
@proximity = ( data, handler ) ->
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


############################################################################################################
unless module.parent?
  BS = @
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
  idx = BS.equality data, probe
  console.log idx, data[ idx ]
  #.........................................................................................................
  idx = BS.equality data, compare
  console.log idx, data[ idx ]
  #.........................................................................................................
  [ lo_idx, hi_idx ] = BS.proximity data, compare
  console.log [ lo_idx, hi_idx, ], [ data[ lo_idx ], data[ hi_idx ], ]




