-- Personal overrides on top of Omarchy's defaults.
--
-- Only deviations live here. Workspaces, tiling, scratchpad, terminal and
-- browser bindings already match the AeroSpace setup on macOS, because that
-- setup was modelled on Omarchy — see the cross-references in
-- stow/macos/.config/aerospace/aerospace.toml.
--
-- See every active binding: omarchy menu keybindings --print

-- Claude takes the assistant slot; ChatGPT moves down to where Omarchy
-- ships Grok. Mirrors Option+Shift+A / Option+Shift+Cmd+A on macOS.
o.rebind("SUPER + SHIFT + A", "Claude", { webapp = "https://claude.ai" })
o.rebind("SUPER + SHIFT + ALT + A", "ChatGPT", { webapp = "https://chatgpt.com" })

-- Mail and calendar are Google, not HEY.
o.rebind("SUPER + SHIFT + C", "Calendar", { webapp = "https://calendar.google.com" })
o.rebind("SUPER + SHIFT + E", "Email", { webapp = "https://mail.google.com" })
o.rebind("SUPER + SHIFT + ALT + E", "New email", { webapp = "https://mail.google.com/mail/?view=cm&fs=1" })

-- WhatsApp is the messenger here rather than Signal. Omarchy keeps WhatsApp
-- on SUPER + SHIFT + ALT + G too, so that chord still works.
o.rebind("SUPER + SHIFT + G", "WhatsApp", { webapp = "https://web.whatsapp.com/", focus = true })

-- Zed rather than the default editor, matching Option+Shift+N on macOS.
-- SUPER + SHIFT + W keeps Omarchy's Omawrite; Typora is a macOS-only habit
-- and there is no reason to install it here.
o.rebind("SUPER + SHIFT + N", "Editor", { launch = "zed" })

-- Apps Omarchy has no default binding for. Both keys are free upstream.
o.bind("SUPER + SHIFT + I", "Notion", { webapp = "https://notion.so" })
o.bind("SUPER + SHIFT + L", "Linear", { webapp = "https://linear.app" })
