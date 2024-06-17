local FloatLayout = require("clojure-test.ui.layout.float")

local config = require("clojure-test.config")
local utils = require("clojure-test.utils")

local M = {}

local function is_window_visible(win_id)
  local windows = vim.api.nvim_tabpage_list_wins(0)
  for _, id in ipairs(windows) do
    if id == win_id then
      return true
    end
  end
end

local function cycle_focus(layout, direction)
  local windows = { layout.windows.tree, layout.windows.left, layout.windows.right }
  windows = vim.tbl_filter(function(window)
    return is_window_visible(window.winid)
  end, windows)

  local currently_focused_window = vim.api.nvim_get_current_win()
  local current_index = 1
  for i, win in ipairs(windows) do
    if win.winid == currently_focused_window then
      current_index = i
    end
  end

  local index = current_index + direction
  if index < 1 then
    index = #windows
  end

  if index > #windows then
    index = 1
  end

  local window = windows[index]
  vim.api.nvim_set_current_win(window.winid)
end

local function setup_bindings(popup, layout, on_event)
  for _, chord in ipairs(utils.into_table(config.keys.ui.cycle_focus_forwards)) do
    popup:map("n", chord, function()
      cycle_focus(layout, 1)
    end, { noremap = true })
  end

  for _, chord in ipairs(utils.into_table(config.keys.ui.cycle_focus_backwards)) do
    popup:map("n", chord, function()
      cycle_focus(layout, -1)
    end, { noremap = true })
  end

  local event = require("nui.utils.autocmd").event
  popup:on({ event.WinLeave }, function()
    vim.schedule(function()
      local currently_focused_window = vim.api.nvim_get_current_win()
      local found = false
      for _, win in pairs(layout.windows) do
        if win.winid == currently_focused_window then
          found = true
        end
      end

      if found then
        return
      end

      on_event({
        type = "on-focus-lost",
      })
    end)
  end, {})
end

function M.create(on_event)
  local layout_fn = FloatLayout
  if config.layout.style == "float" then
    layout_fn = FloatLayout
  end

  local layout = layout_fn()

  function layout:map(mode, chord, fn, opts)
    layout.windows.tree:map(mode, chord, fn, opts)
    layout.windows.left:map(mode, chord, fn, opts)
    layout.windows.right:map(mode, chord, fn, opts)
  end

  setup_bindings(layout.windows.tree, layout, on_event)
  setup_bindings(layout.windows.left, layout, on_event)
  setup_bindings(layout.windows.right, layout, on_event)

  return layout
end

return M
