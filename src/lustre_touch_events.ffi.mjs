export function normalize_touchevent(touchevent) {
  const te = { ...touchevent }
  // Turn TouchList into a regular Array
  te.changedTouches = Array.from(touchevent?.changedTouches ?? [])
  te.targetTouches = Array.from(touchevent?.targetTouches ?? [])
  te.touches = Array.from(touchevent?.touches ?? [])
  return te
}
