-- Migrated from hyprland.conf (deprecated hyprlang format, removed in Hyprland 0.57)
-- Reference: https://wiki.hypr.land/Configuring/

------------------
---- MONITORS ----
------------------

hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "auto-up", scale = 1, bitdepth = 10, cm = "hdr" })
hl.monitor({
	output = "desc:AOC 27E2UA RLTR9HA000910",
	mode = "preferred",
	position = "auto-left",
	scale = 1,
	bitdepth = 10,
	cm = "hdr",
})
hl.monitor({
	output = "desc:Technical Concepts Ltd 55S421",
	mode = "3840x2160@60",
	position = "auto-up",
	scale = 2,
	bitdepth = 10,
	cm = "hdr",
})
hl.monitor({
	output = "eDP-1",
	mode = "preferred",
	position = "0x0",
	scale = 2,
	bitdepth = 10,
	supports_hdr = 1,
	supports_wide_color = 1,
})

-- trigger when the switch is turning off
hl.bind("switch:off:Lid Switch", hl.dsp.exec_cmd('hyprctl keyword monitor "eDP-1, enable"'), { locked = true })
-- trigger when the switch is turning on
hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd('hyprctl keyword monitor "eDP-1, disable"'), { locked = true })

---------------------
---- MY PROGRAMS ----
---------------------

local terminal = "ghostty"
local fileManager = "thunar"
local menu = "rofi -show drun"
local browser = "zen-browser"

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
	hl.exec_cmd("hyprpolkitagent & hyprsunset & hyprpaper & dunst & udiskie")
	hl.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/battery-alert.sh")
	hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
	general = {
		gaps_in = 0,
		gaps_out = 0,
		border_size = 1,

		col = {
			active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
			inactive_border = "rgba(595959aa)",
		},

		resize_on_border = false,
		allow_tearing = false,
		layout = "master",
	},

	decoration = {
		rounding = 0,
		active_opacity = 1.0,
		inactive_opacity = 1.0,

		blur = {
			enabled = false,
			size = 3,
			passes = 1,
			vibrancy = 0.1696,
		},
	},

	animations = {
		enabled = false,
	},
})

hl.config({
	dwindle = {
		preserve_split = true,
	},
})

hl.config({
	master = {
		orientation = "left",
	},
})

hl.config({
	misc = {
		force_default_wallpaper = 0,
		disable_hyprland_logo = true,
	},
})

---------------
---- INPUT ----
---------------

hl.config({
	input = {
		kb_layout = "us",
		kb_variant = "",
		kb_model = "",
		kb_options = "caps:swapescape",
		kb_rules = "",

		follow_mouse = 1,
		sensitivity = 0,

		touchpad = {
			natural_scroll = false,
			disable_while_typing = true,
		},
	},
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

-- Example binds
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exit())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("standard-notes"))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("signal"))
hl.bind(mainMod .. " + K", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/split_keeb_layout.sh show"))
hl.bind(
	mainMod .. " + K",
	hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/split_keeb_layout.sh hide"),
	{ release = true, transparent = true }
)
hl.bind(
	mainMod .. " + L",
	hl.dsp.exec_cmd(
		"brightnessctl -d kbd_backlight g | grep -q '^0$' && brightnessctl -d kbd_backlight s 255 || brightnessctl -d kbd_backlight s 0"
	)
)

-- distraction free x posting
hl.bind(
	"SUPER + X",
	hl.dsp.exec_cmd(
		[[sh -c 'zen-browser --new-window "https://x.com/intent/tweet" & sleep 1.2 && hyprctl dispatch setfloating active && hyprctl dispatch resizeactive exact 600 650 && hyprctl dispatch centerwindow && hyprctl dispatch pin active']]
	)
)

hl.window_rule({
	name = "kb-overlay",
	match = { title = "^(kb-overlay)$" },
	float = true,
	center = true,
	pin = true,
	no_anim = true,
	no_blur = true,
	no_shadow = true,
	border_size = 0,
})

-- Screenshots
hl.bind(mainMod .. " + PRINT", hl.dsp.exec_cmd("hyprshot -m window"))
hl.bind("PRINT", hl.dsp.exec_cmd("hyprshot -m output"))
hl.bind(mainMod .. " + SHIFT + PRINT", hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("hyprshot -m region"))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
	local key = i % 10
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + M", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Move active window to a monitor in a specific direction
hl.bind(mainMod .. " + CTRL + left", hl.dsp.exec_cmd("hyprctl dispatch movewindow mon:l"))
hl.bind(mainMod .. " + CTRL + right", hl.dsp.exec_cmd("hyprctl dispatch movewindow mon:r"))
hl.bind(mainMod .. " + CTRL + up", hl.dsp.exec_cmd("hyprctl dispatch movewindow mon:u"))
hl.bind(mainMod .. " + CTRL + down", hl.dsp.exec_cmd("hyprctl dispatch movewindow mon:d"))

-- Function keys
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"))
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))
