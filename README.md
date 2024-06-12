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
  end
}
```

Note that currently this requires adding a companion dependency to your repl:

```bash
clojure -Sdeps '{:extra-deps {io.julienvincent/clojure-test {:mvn/version "0.0.1"} nrepl/nrepl {:mvn/version "1.0.0"} cider/cider-nrepl {:mvn/version "0.28.5"}}}' \
 -m nrepl.cmdline \
 --middleware '[cider.nrepl/cider-middleware]'
```

## Project Status

This is very **alpha software**. It's built for my personal use and I am developing it out as I go. Use at your own risk

## Configuration

```lua
local clojure_test = require("clojure-test")
clojure_test.setup({
  use_default_keys = true,

  -- list of default keybindings
  keys = {
    run_tests = "<localleader>tr",
    run_tests_in_ns = "<localleader>tn",
    rerun_previous = "<localleader>tp",
    load_test_namespaces = "<localleader>tl",
  }
})
```
