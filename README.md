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

```bash
clojure -Sdeps '{:extra-deps {io.julienvincent/clojure-test {:mvn/version "0.0.1"} nrepl/nrepl {:mvn/version "1.0.0"} cider/cider-nrepl {:mvn/version "0.28.5"}}}' \
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
    global = {
      run_all_tests = "<localleader>ta",
      run_tests = "<localleader>tr",
      run_tests_in_ns = "<localleader>tn",
      rerun_previous = "<localleader>tp",
      load_test_namespaces = "<localleader>tl",
    },

    ui = {
      expand_node = "l",
      collapse_node = "h",
      go_to = "<Cr>",

      cycle_focus_forwards = "<Tab>",
      cycle_focus_backwards = "<S-Tab>",

      quit = { "<Esc>", "q" },
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

## Reload namespaces before run

A very useful configuration snippet is to set up a hook to save modified buffers and reload namespaces before running
tests. This means that while you are working on changes you can just run the tests that cover your changes without
having to go back and re-eval everything.

This example makes use of [tonsky/clj-reload](https://github.com/tonsky/clj-reload) which ensures that namespaces are
reloaded in the order they depend on each other. You can adapt this example to use whatever reload mechanism you wish.

```lua
require("clojure-test").setup({
  hooks = {
    before_run = function(_)
      -- write all modified buffers
      vim.api.nvim_command("wa")

      local client = require("conjure.client")
      local fn = require("conjure.eval")["eval-str"]

      client["with-filetype"](
        "clojure",
        fn,
        vim.tbl_extend("force", {
          origin = "clojure_test.hooks.before_run",
          context = "user",
          code = [[ ((requiring-resolve 'clj-reload.core/reload)) ]],
        }, opts)
      )
    end
  }
})
```
