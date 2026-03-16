import Carbon

let sources = TISCreateInputSourceList(nil, false).takeRetainedValue() as! [TISInputSource]
let keyboards = sources.filter {
    let category = unsafeBitCast(TISGetInputSourceProperty($0, kTISPropertyInputSourceCategory), to: CFString.self)
    let selectable = unsafeBitCast(TISGetInputSourceProperty($0, kTISPropertyInputSourceIsSelectCapable), to: CFBoolean.self)
    return category == kTISCategoryKeyboardInputSource && CFBooleanGetValue(selectable)
}

let currentId = unsafeBitCast(
    TISGetInputSourceProperty(TISCopyCurrentKeyboardInputSource().takeRetainedValue(), kTISPropertyInputSourceID),
    to: CFString.self
) as String

guard let currentIndex = keyboards.firstIndex(where: {
    let id = unsafeBitCast(TISGetInputSourceProperty($0, kTISPropertyInputSourceID), to: CFString.self) as String
    return id == currentId
}) else { exit(1) }

let nextIndex = (currentIndex + 1) % keyboards.count
TISSelectInputSource(keyboards[nextIndex])
