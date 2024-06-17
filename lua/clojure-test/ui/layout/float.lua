local NuiLayout = require("nui.layout")
local NuiPopup = require("nui.popup")

return function()
  local top_left_popup = NuiPopup({
    border = {
      style = "rounded",
      text = {
        top = " Expected ",
        top_align = "left",
      },
    },
  })
  local top_right_popup = NuiPopup({
    border = {
      style = "rounded",
      text = {
        top = " Result ",
        top_align = "left",
      },
    },
  })

  local report_popup = NuiPopup({
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

  local double = NuiLayout.Box({
    NuiLayout.Box({
      NuiLayout.Box(top_left_popup, { grow = 1 }),
      NuiLayout.Box(top_right_popup, { grow = 1 }),
    }, { dir = "row", size = "70%" }),

    NuiLayout.Box(report_popup, { size = "30%" }),
  }, { dir = "col" })

  local single = NuiLayout.Box({
    NuiLayout.Box({
      NuiLayout.Box(top_right_popup, { grow = 1 }),
    }, { dir = "row", size = "70%" }),

    NuiLayout.Box(report_popup, { size = "30%" }),
  }, { dir = "col" })

  local root_layout = NuiLayout({
    position = "50%",
    relative = "editor",
    size = {
      width = 150,
      height = 60,
    },
  }, single)

  local FloatLayout = {
    layout = root_layout,

    windows = {
      tree = report_popup,
      left = top_left_popup,
      right = top_right_popup,
    },
  }

  function FloatLayout:mount()
    root_layout:mount()
  end

  function FloatLayout:render_single()
    root_layout:update(single)
  end

  function FloatLayout:render_double()
    root_layout:update(double)
  end

  function FloatLayout:unmount()
    root_layout:unmount()
  end

  function FloatLayout:on_focus_lost()
    return false
  end

  return FloatLayout
end
