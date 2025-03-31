import gleam/dynamic
import gleam/dynamic/decode
import gleam/list
import gleam/result
import lustre/attribute.{type Attribute}

/// Touch type corresponding to:
/// https://developer.mozilla.org/en-US/docs/Web/API/Touch
pub type Touch {
  Touch(
    identifier: Int,
    screen_x: Float,
    screen_y: Float,
    client_x: Float,
    client_y: Float,
    page_x: Float,
    page_y: Float,
  )
}

/// Touch event containing the touch lists.
pub type TouchEvent {
  TouchEvent(
    changed_touches: List(Touch),
    target_touches: List(Touch),
    touches: List(Touch),
  )
}

/// This is needed to turn TouchList into a regular Array
@external(javascript, "./lustre_touch_events.ffi.mjs", "normalize_touchevent")
fn normalize_touchevent(touchevent: dynamic.Dynamic) -> dynamic.Dynamic

/// `touchstart` event:
/// https://developer.mozilla.org/en-US/docs/Web/API/Element/touchstart_event
pub fn on_touch_start(msg: fn(TouchEvent) -> a) -> Attribute(a) {
  on_touch_event("touchstart", msg)
}

/// `touchmove` event:
/// https://developer.mozilla.org/en-US/docs/Web/API/Element/touchmove_event
pub fn on_touch_move(msg: fn(TouchEvent) -> a) -> Attribute(a) {
  on_touch_event("touchmove", msg)
}

/// `touchend` event:
/// https://developer.mozilla.org/en-US/docs/Web/API/Element/touchend_event
pub fn on_touch_end(msg: fn(TouchEvent) -> a) -> Attribute(a) {
  on_touch_event("touchend", msg)
}

/// `touchcancel` event:
/// https://developer.mozilla.org/en-US/docs/Web/API/Element/touchcancel_event
pub fn on_touch_cancel(msg: fn(TouchEvent) -> a) -> Attribute(a) {
  on_touch_event("touchcancel", msg)
}

/// generic touch event helper
fn on_touch_event(event: String, msg: fn(TouchEvent) -> a) -> Attribute(a) {
  attribute.on(event, fn(x) {
    normalize_touchevent(x)
    |> decode.run(touch_event_decoder())
    |> result.map(msg)
    |> result.map_error(to_dynamic_errors)
  })
}

fn touch_event_decoder() -> decode.Decoder(TouchEvent) {
  use changed_touches <- decode.field(
    "changedTouches",
    decode.list(touch_decoder()),
  )
  use target_touches <- decode.field(
    "targetTouches",
    decode.list(touch_decoder()),
  )
  use touches <- decode.field("touches", decode.list(touch_decoder()))
  decode.success(TouchEvent(changed_touches:, target_touches:, touches:))
}

fn touch_decoder() -> decode.Decoder(Touch) {
  use identifier <- decode.field("identifier", decode.int)
  use screen_x <- decode.field("screenX", decode.float)
  use screen_y <- decode.field("screenY", decode.float)
  use client_x <- decode.field("clientX", decode.float)
  use client_y <- decode.field("clientY", decode.float)
  use page_x <- decode.field("pageX", decode.float)
  use page_y <- decode.field("pageY", decode.float)
  decode.success(Touch(
    identifier:,
    screen_x:,
    screen_y:,
    client_x:,
    client_y:,
    page_x:,
    page_y:,
  ))
}

/// Maps DecodeErrors to deprecated dynamic DecodeErrors because
/// Lustre still uses the old DecodeError type.
fn to_dynamic_errors(
  errors: List(decode.DecodeError),
) -> List(dynamic.DecodeError) {
  list.map(errors, fn(x: decode.DecodeError) {
    dynamic.DecodeError(expected: x.expected, found: x.found, path: x.path)
  })
}
