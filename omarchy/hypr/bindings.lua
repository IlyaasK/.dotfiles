-- Personaliased Omarchy keybinding overrides (loaded after Omarchy's defaults).
-- Keep only personal overrides; Omarchy owns the rest.
-- See live bindings:  omarchy menu keybindings --print

-- learnomarchy
o.bind("SUPER + ALT + L", "Learnomarchy", os.getenv("HOME") .. "/.local/bin/learnomarchy")

-- Close windows with Super+Q (harmonized with the Asahi/Mac setup).
hl.unbind("SUPER + W")
o.bind("SUPER + Q", "Close window", hl.dsp.window.close())

-- Launcher: Super+R (moved from Super+SPACE; matches the Asahi/Mac muscle memory).
hl.unbind("SUPER + SPACE")
o.bind("SUPER + R", "Omarchy menu", "omarchy-menu toggle")

-- Standard Notes on Super+N (standardnotes-bin; matches the .desktop Exec).
o.bind("SUPER + N", "Standard Notes", "env DESKTOPINTEGRATION=false /usr/bin/standard-notes")

-- Physical keyboard layout overlay: press Super+Shift+K to toggle show/hide.
o.bind("SUPER + SHIFT + K", "Keyboard layout", os.getenv("HOME") .. "/.config/hypr/scripts/kb-layout-overlay.sh toggle")
