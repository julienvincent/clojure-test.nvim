local report_tree_api = require("clojure-test.ui.report-tree")
local exceptions = require("clojure-test.ui.exceptions")
local layout_api = require("clojure-test.ui.layout")
local config = require("clojure-test.config")
local utils = require("clojure-test.utils")

local M = {}

local function write_clojure_to_buf(buf, contents)
  vim.api.nvim_set_option_value("filetype", "clojure", {
    buf = buf,
  })

  local lines = {}
  if contents then
    lines = vim.split(contents, "\n")
  end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
end

local function handle_on_move(UI, event)
  local node = event.node
  local layout = UI.layout

  if node.assertion then
    if node.assertion.exceptions then
      vim.schedule(function()
        if node.assertion.expected then
          layout:render_double()
          write_clojure_to_buf(layout.windows.left.bufnr, node.assertion.expected)
          exceptions.render_exceptions_to_buf(layout.windows.right.bufnr, node.assertion.exceptions)
          return
        end

        layout:render_single()
        exceptions.render_exceptions_to_buf(layout.windows.right.bufnr, node.assertion.exceptions)
      end)
      return
    end

    vim.schedule(function()
      layout:render_double()
      write_clojure_to_buf(layout.windows.left.bufnr, node.assertion.expected)
      write_clojure_to_buf(layout.windows.right.bufnr, node.assertion.actual)
    end)
    return
  end

  if node.exception then
    vim.schedule(function()
      layout:render_single()
      exceptions.render_exceptions_to_buf(layout.windows.right.bufnr, { node.exception })
    end)
    return
  end

  vim.schedule(function()
    layout:render_single()
    write_clojure_to_buf(layout.windows.right.bufnr, "")
  end)
end

function M.create(on_event)
  local UI = {
    mounted = false,
    layout = nil,
    tree = nil,

    last_active_window = vim.api.nvim_get_current_win(),
  }

  function UI:mount()
    if UI.mounted then
      return
    end

    UI.mounted = true

    UI.layout = layout_api.create(function(event)
      if event.type == "on-focus-lost" then
        if not UI.mounted then
          return
        end
        if not UI.layout:on_focus_lost() then
          UI:unmount()
        end
      end
    end)
    UI.layout:mount()

    UI.tree = report_tree_api.create(UI.layout.windows.tree, function(event)
      if event.type == "hover" then
        return handle_on_move(UI, event)
      end

      on_event(event)
    end)

    for _, chord in ipairs(utils.into_table(config.keys.ui.quit)) do
      UI.layout:map("n", chord, function()
        UI:unmount()
      end, { noremap = true })
    end
  end

  function UI:unmount()
    if not UI.mounted then
      return
    end

    UI.mounted = false
    UI.layout:unmount()
    UI.layout = nil
    UI.tree = nil

    vim.api.nvim_set_current_win(UI.last_active_window)
  end

  function UI:render_reports(reports)
    UI.tree:render_reports(reports)
  end

  function UI:render_exceptions(exception_chain) end

  function UI:on() end

  return UI
end

return M
