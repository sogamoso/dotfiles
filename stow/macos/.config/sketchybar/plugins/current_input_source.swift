import Carbon

// With --count, print how many keyboard sources are enabled, so the bar can
// hide the indicator when there is nothing to switch between
if CommandLine.arguments.contains("--count") {
  let filter = [
    kTISPropertyInputSourceCategory: kTISCategoryKeyboardInputSource,
    kTISPropertyInputSourceIsSelectCapable: true,
  ] as CFDictionary
  let list = TISCreateInputSourceList(filter, false).takeRetainedValue() as NSArray
  print(list.count)
  exit(0)
}

let src = TISCopyCurrentKeyboardInputSource().takeRetainedValue()
let id = unsafeBitCast(TISGetInputSourceProperty(src, kTISPropertyInputSourceID), to: CFString.self) as String
print(id)
