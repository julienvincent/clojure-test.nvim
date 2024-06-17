<div align="center">
  <h1>clojure-test.nvim</h1>
</div>

<div align="center">
  <p>
    Run clojure tests interactively in your repl directly from neovim.
  </p>
</div>

---


## Installation

### Using [folke/lazy.vim](https://github.com/folke/lazy.nvim)

```lua
{
  "julienvincent/clojure-test.nvim",
  config = function()
    require("clojure-test").setup()
  end,
  dependencies = {
    { "nvim-neotest/nvim-nio" },
    { "MunifTanjim/nui.nvim" }
  }
}
```

Note that currently this requires adding a companion dependency to your REPL:

[![Clojars Project](https://img.shields.io/clojars/v/io.julienvincent/clojure-test.svg)](https://clojars.org/io.julienvincent/clojure-test)

```bash
clojure -Sdeps '{:extra-deps {io.julienvincent/clojure-test {:mvn/version "RELEASE"}}}' \
 -m nrepl.cmdline \
 --middleware '[cider.nrepl/cider-middleware]'
```

## Project Status

This is **very alpha software**. It's built for my personal use, and I am developing it out as I go. Use at your own risk.

## Configuration

```lua
local clojure_test = require("clojure-test")
clojure_test.setup({
  -- list of default keybindings
  keys = {
    ui = {
      expand_node = { "l", "<Right>" },
      collapse_node = { "h", "<Left>" },
      go_to = { "<Cr>", "gd" },

      cycle_focus_forwards = "<Tab>",
      cycle_focus_backwards = "<S-Tab>",

      quit = { "q", "<Esc>" },
    },
  },

  hooks = {
    -- This is a hook that will be called with a table of tests that are about to be run. This
    -- can be used as an opportunity to save files and/or reload clojure namespaces.
    --
    -- This combines really well with https://github.com/tonsky/clj-reload
    before_run = function(tests)
    end
  }
})
```

## Usage

Once installed you can call the various API methods to run and load tests or setup keybindings to do this for you.

```lua
local api = require("clojure-test.api")

vim.keymap.set("n", "<localleader>ta", api.run_all_tests, { desc = "Run all tests" })
vim.keymap.set("n", "<localleader>tr", api.run_tests, { desc = "Run tests" })
vim.keymap.set("n", "<localleader>tn", api.run_tests_in_ns, { desc = "Run tests in a namespace" })
vim.keymap.set("n", "<localleader>tp", api.rerun_previous, { desc = "Rerun the most recently run tests" })
vim.keymap.set("n", "<localleader>tl", api.run_tests_in_ns, { desc = "Find and load test namespaces in classpath" })
```

## Reload namespaces before run

A very useful configuration snippet is to set up a hook to save modified buffers and reload namespaces before running
tests. This means that while you are working on changes you can just run the tests that cover your changes without
having to go back and re-eval everything.

This example makes use of [tonsky/clj-reload](https://github.com/tonsky/clj-reload) which ensures that namespaces are
reloaded in the order they depend on each other.

```lua
require("clojure-test").setup({
  hooks = {
    before_run = function(_)
      -- write all modified buffers
      vim.api.nvim_command("wa")

      local client = require("conjure.client")
      local fn = require("conjure.eval")["eval-str"]
      client["with-filetype"]("clojure", fn, {
        origin = "clojure_test.hooks.before_run",
        context = "user",
        code = [[ ((requiring-resolve 'clj-reload.core/reload)) ]],
      })
    end
  }
})
```
