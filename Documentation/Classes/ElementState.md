# ElementState

The `ElementState` class is a snapshot of the **animatable properties** of a form object. It is the "keyframe" unit of the transition engine:

* [`capture()`](#capture) reads the current geometry, font size, colors and corner radius of a form object,
* [`lerp()`](#lerp) interpolates between two states,
* [`apply()`](#apply) writes a state back to any form object.

Instances are JSON-serializable, so a snapshot can be persisted (see [`ElementTransition.capture()`](ElementTransition.md#capture)).

## <a name="Constructor">cs.hero.ElementState.new()</a>

**cs.hero.ElementState.new**( {*name* : Text} ) : `cs.hero.ElementState`

|Parameter|Type||Description|
|---|---|---|---|
| name | Text | → | Name of a form object; when passed, its current state is captured immediately |
| result | cs.hero.ElementState | ← | New `cs.hero.ElementState` |

# Summary

## <a name="Properties">Properties</a>

|Properties|Description|Type|Writable|
|:----------|:-----------|:-----------|:-----------:|
|**.name**| Name of the captured form object | `Text` |<font color="green">✓</font>
|**.type**| Object type (`OBJECT Get type`) | `Integer` |<font color="green">✓</font>
|**.left**<br>**.top**<br>**.right**<br>**.bottom**| Coordinates, in pixels, in the form coordinate system | `Real` |<font color="green">✓</font>
|**.width**<br>**.height**| Width & height, calculated from the coordinates | `Real` |<font color="red">x</font>
|**.fontSize**| Font size in points (`0` when not relevant) | `Real` |<font color="green">✓</font>
|**.foregroundColor**<br>**.backgroundColor**| RGB colors as `0x00RRGGBB` longints; negative values are automatic/system colors | `Integer` |<font color="green">✓</font>
|**.cornerRadius**| Corner radius in pixels; `-1` when the object has none | `Real` |<font color="green">✓</font>
|**.visible**| Visibility of the object when captured (informative — `apply()` does not change visibility) | `Boolean` |<font color="green">✓</font>

## <a name="Functions">Functions</a>

| Functions | Action |
|:-------- |:------ |
|[.**capture** ()](#capture) | Re-reads the current state of `.name` from the form |
|.**copy** () | Returns an independent copy of the state |
|[.**lerp** (*target*; *t* {; *colorMode*})](#lerp) | Returns a new state interpolated between `This` and *target* |
|[.**apply** ({*name*})](#apply) | Applies the state to a form object |

# <a name="capture">.capture()</a>

**.capture**( ) : `cs.hero.ElementState`

### Description

Reads the current geometry, font size, colors, corner radius and visibility of the form object `.name`. Returns `This`.

# <a name="lerp">.lerp()</a>

**.lerp**( *target* : cs.hero.ElementState; *t* : Real {; *colorMode* : Text} ) : `cs.hero.ElementState`

|Parameter|Type||Description|
|---|---|---|---|
| target | cs.hero.ElementState | → | The state at *t* = 1 (`This` is the state at *t* = 0) |
| t | Real | → | Progress, from 0 to 1 (typically already eased) |
| colorMode | Text | → | `"rgb"` (default) or `"hsv"` — see [below](#colors) |
| result | cs.hero.ElementState | ← | New interpolated state |

### Description

Returns a new state interpolated between `This` (*t* = 0) and *target* (*t* = 1). Geometry and font size are interpolated linearly; corner radius only when both states have one, otherwise it snaps at the end.

## <a name="colors">Color interpolation</a>

Colors are interpolated per RGB component by default. That is mathematically correct, but the in-between tones of two distant hues (e.g. blue → orange) are desaturated and can look muddy or greenish. With `colorMode` = `"hsv"`, the interpolation travels the **shortest hue path** in HSV space and the in-between colors stay vivid.

Automatic/system colors (negative values) are never interpolated: they snap at mid-course.

# <a name="apply">.apply()</a>

**.apply**( {*name* : Text} ) : `cs.hero.ElementState`

|Parameter|Type||Description|
|---|---|---|---|
| name | Text | → | Name of the form object to write to; defaults to `.name` |

### Description

Applies the state to a form object: coordinates, font size (when > 0), colors (when at least one is ≥ 0) and corner radius (when ≥ 0 **and** the target object can have one). Visibility is intentionally not touched. Returns `This`.

## <a name="radius">Which objects have a corner radius</a>

The ones `OBJECT SET CORNER RADIUS` accepts: **rectangles**, **inputs** and **text areas** (the last two in project databases only). Anything else captures `-1` and is left alone.

For inputs and text areas, 4D only honours the radius with a `none`, `solid` or `dotted` border style. Nothing to watch out for, though: an object with another style simply reports no radius, so it is captured as `-1` like any other.
