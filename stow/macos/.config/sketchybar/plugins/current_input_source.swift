import Carbon

let src = TISCopyCurrentKeyboardInputSource().takeRetainedValue()
let id = unsafeBitCast(TISGetInputSourceProperty(src, kTISPropertyInputSourceID), to: CFString.self) as String
print(id)
