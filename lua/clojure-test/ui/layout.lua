local Layout = require("nui.layout")
local Popup = require("nui.popup")

local M = {}

local function setup_quit_bindings(popup, layout)
  popup:map("n", "q", function()
    layout:unmount()
  end, { noremap = true })
  popup:map("n", "<Esc>", function()
    layout:unmount()
  end, { noremap = true })
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
