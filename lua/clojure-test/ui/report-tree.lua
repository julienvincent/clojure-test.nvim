local exceptions = require("clojure-test.ui.exceptions")

local NuiLine = require("nui.line")
local NuiText = require("nui.text")
local NuiTree = require("nui.tree")

local function report_to_line(report)
  local line = {}

  if report.status == "pending" then
    table.insert(line, NuiText(" "))
  end
  if report.status == "failed" then
    table.insert(line, NuiText(" ", "Error"))
  end
  if report.status == "passed" then
    table.insert(line, NuiText(" ", "Green"))
  end

  table.insert(line, NuiText(vim.split(report.test, "/")[1], "Comment"))
  table.insert(line, NuiText("/"))
  table.insert(line, NuiText(vim.split(report.test, "/")[2], "Label"))

  return line
end

local function assertion_to_line(assertion)
  local line = {}

  table.insert(line, NuiText(" "))
  if assertion.type == "pass" then
    table.insert(line, NuiText(" ", "Green"))
    table.insert(line, NuiText("Pass"))
  else
    table.insert(line, NuiText(" ", "Error"))
    table.insert(line, NuiText("Fail"))
  end

  return line
end

local function assertion_to_node(assertion)
  local line = assertion_to_line(assertion)

  local node = NuiTree.Node({
    line = line,
    assertion = assertion,
  })

  if assertion.type ~= "pass" then
    node:expand()
  end

  return node
end

local function report_to_node(report)
  local report_line = report_to_line(report)

  local children = {}
  for _, assertion in ipairs(report.assertions) do
    table.insert(children, assertion_to_node(assertion))
  end

  local node = NuiTree.Node({ line = report_line }, children)
  if report.status == "failed" then
    node:expand()
  end
  return node
end

local function reports_to_nodes(reports)
  local nodes = {}
  for _, report in pairs(reports) do
    table.insert(nodes, report_to_node(report))
  end
  return nodes
end

local function write_clojure_to_buf(buf, contents)
  vim.api.nvim_buf_set_option(buf, "filetype", "clojure")

  local lines = {}
  if contents then
    lines = vim.split(contents, "\n")
  end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
end

local M = {}

function M.create_tree(layout)
  local window = layout.windows.tree

  local tree = NuiTree({
    winid = window.winid,
    nodes = {},
    prepare_node = function(node)
      local line = NuiLine()

      for _ = 1, node:get_depth() do
        line:append(" ")
      end

      if node:has_children() then
        if node:is_expanded() then
          line:append("- ")
        else
          line:append("+ ")
        end
      else
        line:append("  ")
      end

      for _, text in ipairs(node.line) do
        line:append(text)
      end

      return line
    end,
  })

  local map_options = { noremap = true, nowait = true }
  window:map("n", "<Left>", function()
    local node = tree:get_node()

    if not node:has_children() then
      local node_id = node:get_parent_id()
      if node_id then
        node = tree:get_node(node_id)
      end
    end

    if node and node:collapse() then
      tree:render()
    end
  end, map_options)

  window:map("n", "<Right>", function()
    local node = tree:get_node()

    if node:expand() then
      tree:render()
    end
  end, map_options)

  local event = require("nui.utils.autocmd").event

  window:on({ event.CursorMoved }, function()
    local node = tree:get_node()

    if node.assertion then
      write_clojure_to_buf(layout.windows.left.bufnr, node.assertion.expected)

      if node.assertion.exception then
        exceptions.render_exception_to_buf(layout.windows.right.bufnr, node.assertion.exception)
      else
        write_clojure_to_buf(layout.windows.right.bufnr, node.assertion.actual)
      end
    end
  end, {})

  local ReportTree = {
    tree = tree,
  }

  function ReportTree:set_reports(reports)
    tree:set_nodes(reports_to_nodes(reports))
  end

  function ReportTree:render()
    tree:render()
  end

  return ReportTree
end

return M
