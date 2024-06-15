local config = require("clojure-test.config")
local utils = require("clojure-test.utils")
local Layout = require("nui.layout")
local Popup = require("nui.popup")

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

local function setup_quit_bindings(popup, layout)
  for _, chord in ipairs(utils.into_table(config.keys.ui.quit)) do
    popup:map("n", chord, function()
      layout:unmount()
    end, { noremap = true })
  end

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
end

function M.create_test_layout()
  local top_left_popup = Popup({
    border = {
      style = "rounded",
      text = {
        top = " Expected ",
        top_align = "left",
      },
    },
  })
  local top_right_popup = Popup({
    border = {
      style = "rounded",
      text = {
        top = " Result ",
        top_align = "left",
      },
    },
  })

  local report_popup = Popup({
    border = {
      style = "rounded",
      text = {
        top = " Report ",
        top_align = "left",
      },
    },
    enter = true,
    focusable = true,
  })

  local layout_side_by_side = Layout.Box({
    Layout.Box({
      Layout.Box(top_left_popup, { grow = 1 }),
      Layout.Box(top_right_popup, { grow = 1 }),
    }, { dir = "row", size = "70%" }),

    Layout.Box(report_popup, { size = "30%" }),
  }, { dir = "col" })

  local layout_single = Layout.Box({
    Layout.Box({
      Layout.Box(top_right_popup, { grow = 1 }),
    }, { dir = "row", size = "70%" }),

    Layout.Box(report_popup, { size = "30%" }),
  }, { dir = "col" })

  local layout = Layout({
    position = "50%",
    relative = "editor",
    size = {
      width = 150,
      height = 60,
    },
  }, layout_side_by_side)

  local TestLayout = {
    layout = layout,

    windows = {
      tree = report_popup,
      left = top_left_popup,
      right = top_right_popup,
    },

    last_active_window = vim.api.nvim_get_current_win(),
  }

  function TestLayout:mount()
    layout:mount()
  end

  function TestLayout:hide_left()
    top_left_popup:hide()
    layout:update(layout_single)
  end

  function TestLayout:show_left()
    top_left_popup:show()
    layout:update(layout_side_by_side)
  end

  function TestLayout:unmount()
    layout:unmount()
    vim.api.nvim_set_current_win(TestLayout.last_active_window)
  end

  setup_quit_bindings(report_popup, TestLayout)
  setup_quit_bindings(top_left_popup, TestLayout)
  setup_quit_bindings(top_right_popup, TestLayout)

  return TestLayout
end

return M
