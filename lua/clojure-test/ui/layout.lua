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
  local top_left_popup = Popup({ border = "rounded" })
  local top_right_popup = Popup({ border = "rounded" })

  local report_popup = Popup({
    border = "rounded",
    enter = true,
    focusable = true,
  })

  local layout = Layout(
    {
      position = "50%",
      relative = "editor",
      size = {
        width = 150,
        height = 60,
      },
    },
    Layout.Box({
      Layout.Box({
        Layout.Box(top_left_popup, { size = "50%" }),
        Layout.Box(top_right_popup, { size = "50%" }),
      }, { dir = "row", size = "60%" }),

      Layout.Box(report_popup, { size = "40%" }),
    }, { dir = "col" })
  )

  local TestLayout = {
    layout = layout,

    windows = {
      tree = report_popup,
      left = top_left_popup,
      right = top_right_popup,
    },
  }

  function TestLayout:mount()
    layout:mount()
  end

  function TestLayout:unmount()
    layout:unmount()
  end

  setup_quit_bindings(report_popup, TestLayout)
  setup_quit_bindings(top_left_popup, TestLayout)
  setup_quit_bindings(top_right_popup, TestLayout)

  return TestLayout
end

return M
