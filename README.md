<div align="center">
  <h1>clojure-test.nvim</h1>
</div>

<div align="center">
  <p>
    Run clojure tests interactively in your repl directly from neovim.
  </p>
</div>

---

![clojure-test-example](https://github.com/user-attachments/assets/231b8ff4-9402-4f22-b313-7c7b21fe6ae3)

This is a plugin to make working with Clojure tests within Neovim a lot more user-friendly. Here are some of the
features:

+ Interactively run tests from anywhere in the project
  + Provides selection UI's for picking namespaces or individual tests
+ Easily re-run previous or failing tests without having to navigate back to test namespaces
+ Provide a more human-readable interface
+ Render exceptions in a more human friendly manner
+ Allow go-to-definition on test reports
  + Go to where an exception was thrown
  + Go to failing tests
+ Allow running hooks before executing tests
  + Save files and or reload changed namespaces

See the [feature demo](#feature-demo) for a quick overview.

> [!WARNING]
>
> This is **very alpha software**. It's built for my personal use, and I am developing it out as I go. Use at your own
> risk.

## Installation

### Using [folke/lazy.vim](https://github.com/folke/lazy.nvim)

```lua
{
  "julienvincent/clojure-test.nvim",
  config = function()
    require("clojure-test").setup()
  end
}
```

#### Neovim Dependencies

+ [nui.nvim](https://github.com/MunifTanjim/nui.nvim)
+ [nvim-nio](https://github.com/nvim-neotest/nvim-nio)
+ [conjure](https://github.com/olical/conjure) [semi-optional]

#### Clojure Dependencies

[![Clojars Project](https://img.shields.io/clojars/v/io.julienvincent/clojure-test.svg)](https://clojars.org/io.julienvincent/clojure-test)

> [!NOTE]
>
> This plugin currently requires the `io.julienvincent/clojure-test` companion clojure dependency to be available on
> your classpath.

Configure an alias in the project or user level deps.edn file to include the appropriate dependencies. For example you
could modify your `$XDG_CONFIG_HOME/clojure/deps.edn` or `$HOME/.clojure/deps.edn` file as follows:

```clojure
{:aliases
 {:nrepl {:extra-deps {;; Assuming you already have something like this
                       nrepl/nrepl {:mvn/version "1.0.0"}
                       cider/cider-nrepl {:mvn/version "0.42.1"}

                       ;; Add the companion dependency
                       io.julienvincent/clojure-test {:mvn/version "RELEASE"}}
          :main-opts  ["--main" "nrepl.cmdline"
                       "--middleware" "[cider.nrepl/cider-middleware]"
                       "--interactive"]}}}
```

Or alternatively you can include them inline with the following `clojure` command

```bash
clojure -Sdeps '{:deps {nrepl/nrepl {:mvn/version "1.0.0"}
                        cider/cider-nrepl {:mvn/version "0.28.5"}
                        io.julienvincent/clojure-test {:mvn/version "RELEASE"}}}' \
        -M -m nrepl.cmdline \
        --middleware '[cider.nrepl/cider-middleware]'
```

---

#### Why the Clojure dependency?

This plugin currently requires executing a lot of logic on the Clojure side, and it needs to format/parse input and
output in a way that is easily compatible with the Lua plugin - which requires other transient dependencies.

I would like for a future version of this plugin to not require this companion dependency but for the moment it is the
simplest approach.

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

Once installed you can call the various API methods to run and load tests or setup key bindings to do this for you.

```lua
local api = require("clojure-test.api")

vim.keymap.set("n", "<localleader>ta", api.run_all_tests, { desc = "Run all tests" })
vim.keymap.set("n", "<localleader>tr", api.run_tests, { desc = "Run tests" })
vim.keymap.set("n", "<localleader>tn", api.run_tests_in_ns, { desc = "Run tests in a namespace" })
vim.keymap.set("n", "<localleader>tp", api.rerun_previous, { desc = "Rerun the most recently run tests" })
vim.keymap.set("n", "<localleader>tl", api.run_tests_in_ns, { desc = "Find and load test namespaces in classpath" })
```

## Feature Demo

![clojure-test-demo](https://github.com/user-attachments/assets/d54338b6-de25-4b10-a613-2ec9ee4b984b)

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

## Architecture

This is still TBD

## Custom Backends

This plugin uses a configurable backend protocol to communicate with the Clojure nREPL server. This backend is
responsible for performing discovery of test namespaces and tests, as well as executing these tests and providing back
the test reports.

By default, clojure-test is configured to use a built-in [Conjure](https://github.com/olical/conjure) REPL backend. You
can find the relevant implementations
[here](https://github.com/julienvincent/clojure-test.nvim/blob/master/lua/clojure-test/backends/repl.lua) and
[here](https://github.com/julienvincent/clojure-test.nvim/blob/master/lua/clojure-test/clients/conjure.lua).

As an example, here is how the default backend is configured:

```lua
local backends = require("clojure-test.backends")
local clients = require("clojure-test.clients")

require("clojure-test").setup({
  backend = backends.repl.create(clients.conjure),
})
```

Or you can implement your own backend.
