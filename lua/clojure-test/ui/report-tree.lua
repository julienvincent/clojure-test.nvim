local config = require("clojure-test.config")
local utils = require("clojure-test.utils")

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

  if assertion.type == "pass" then
    table.insert(line, NuiText(" ", "Green"))
    table.insert(line, NuiText("Pass"))
  else
    table.insert(line, NuiText(" ", "Error"))
    table.insert(line, NuiText("Fail"))
  end

  return line
end

local function exceptions_to_nodes(exceptions)
  local nodes = {}
  for _, ex in ipairs(exceptions) do
    local line = {
      NuiText(" ", "DiagnosticWarn"),
      NuiText(ex["class-name"], "TSException"),
    }

    local node = NuiTree.Node({
      line = line,
      exception = ex,
    })
    table.insert(nodes, 1, node)
  end
  return nodes
end

local function assertion_to_node(test, assertion)
  local line = assertion_to_line(assertion)

  local children = exceptions_to_nodes(assertion.exceptions or {})

  local node = NuiTree.Node({
    line = line,
    assertion = assertion,
    test = test,
  }, children)

  if assertion.type ~= "pass" then
    node:expand()
  end

  return node
end

local function report_to_node(report)
  local report_line = report_to_line(report)

  local children = {}
  for _, assertion in ipairs(report.assertions) do
    table.insert(children, assertion_to_node(report.test, assertion))
  end

  local node = NuiTree.Node({
    line = report_line,
    test = report.test,
  }, children)

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

local M = {}

function M.create(window, on_event)
  local tree = NuiTree({
    winid = window.winid,
    ns_id = "testns",
    nodes = {},
    prepare_node = function(node)
      local line = NuiLine()

      line:append(string.rep("  ", node:get_depth() - 1))

      if node:has_children() then
        if node:is_expanded() then
          line:append(" ", "Comment")
        else
          line:append(" ", "Comment")
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

  local ReportTree = {
    tree = tree,
  }

  local map_options = { noremap = true, nowait = true }

  for _, chord in ipairs(utils.into_table(config.keys.ui.collapse_node)) do
    window:map("n", chord, function()
      local node = tree:get_node()

      if not node:has_children() or not node:is_expanded() then
        local node_id = node:get_parent_id()
        if node_id then
          node = tree:get_node(node_id)
        end
      end

      if node and node:collapse() then
        tree:render()
      end
    end, map_options)
  end

  for _, chord in ipairs(utils.into_table(config.keys.ui.expand_node)) do
    window:map("n", chord, function()
      local node = tree:get_node()
      if node:expand() then
        tree:render()
      end
    end, map_options)
  end

  for _, chord in ipairs(utils.into_table(config.keys.ui.go_to)) do
    window:map("n", chord, function()
      local node = tree:get_node()
      if not node then
        return
      end

      on_event({
        type = "go-to",
        node = node,
      })
    end, map_options)
  end

  local event = require("nui.utils.autocmd").event
  window:on({ event.CursorMoved }, function()
    local node = tree:get_node()
    if not node then
      return
    end

    on_event({
      type = "hover",
      node = node,
    })
  end, {})

  function ReportTree:render_reports(reports)
    tree:set_nodes(reports_to_nodes(reports))
    tree:render()
  end

  return ReportTree
end

return M
