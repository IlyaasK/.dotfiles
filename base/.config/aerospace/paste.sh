#!/bin/zsh

/usr/bin/osascript <<'APPLESCRIPT'
tell application "System Events"
    tell first application process whose frontmost is true
        click menu item "Paste" of menu "Edit" of menu bar 1
    end tell
end tell
APPLESCRIPT
