-- Omarchy look'n'feel: no gaps, full-monitor use, clear focused-window border.
hl.config({
  general = {
    gaps_in = 0,
    gaps_out = 0,
    border_size = 2,
    col = {
      -- Focused window: bright gradient border. Unfocused: transparent (no border).
      active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
      inactive_border = "rgba(00000000)",
    },
  },
})

-- Physical keyboard-layout overlay: float, center, pin, no border.
hl.window_rule({
  name = "kb-overlay",
  match = { title = "^kb-overlay$" },
  float = true,
  center = true,
  pin = true,
  border_size = 0,
})
