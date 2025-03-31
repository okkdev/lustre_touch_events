export function normalize_touchevent(touchevent) {
  const te = { ...touchevent }
  te.changedTouches = Array.from(touchevent?.changedTouches ?? [])
  te.targetTouches = Array.from(touchevent?.targetTouches ?? [])
  te.touches = Array.from(touchevent?.touches ?? [])
  return te
}
