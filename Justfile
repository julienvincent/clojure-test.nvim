build:
    clojure -T:build build

release:
    clojure -T:build release

[macos]
prepare-nvim channel:
  #!/usr/bin/env sh
  set -eo pipefail
  NVIM_DIR=".build/nvim/{{ channel }}"

  test -d $NVIM_DIR || {
    mkdir -p $NVIM_DIR

    curl -L https://github.com/neovim/neovim/releases/download/{{ channel }}/nvim-macos-$(arch).tar.gz > ./.build/nvim-macos.tar.gz
    xattr -c ./.build/nvim-macos.tar.gz
    tar xzf ./.build/nvim-macos.tar.gz -C $NVIM_DIR --strip-components=1
    rm ./.build/nvim-macos.tar.gz
  }

[linux]
prepare-nvim channel:
  #!/usr/bin/env sh
  set -eo pipefail
  NVIM_DIR=".build/nvim/{{ channel }}"

  test -d $NVIM_DIR || {
    mkdir -p $NVIM_DIR

    curl -L https://github.com/neovim/neovim/releases/download/{{ channel }}/nvim-linux64.tar.gz > ./.build/nvim-linux64.tar.gz
    tar xzf ./.build/nvim-linux64.tar.gz -C $NVIM_DIR --strip-components=1
    rm ./.build/nvim-linux64.tar.gz
  }

prepare-dependencies:
  #!/usr/bin/env sh
  set -eo pipefail
  test -d .build/dependencies || {
    mkdir -p ./.build/dependencies
    git clone --depth 1 https://github.com/nvim-lua/plenary.nvim ./.build/dependencies/plenary.nvim
    git clone --depth 1 https://github.com/nvim-neotest/nvim-nio ./.build/dependencies/nvim-nio
    git clone --depth 1 https://github.com/MunifTanjim/nui.nvim ./.build/dependencies/nui.nvim
  }

prepare channel: (prepare-nvim channel) prepare-dependencies

test channel="stable" file="": (prepare channel)
  #!/usr/bin/env sh
  NVIM_DIR=".build/nvim/{{ channel }}"

  ./$NVIM_DIR/bin/nvim --version
  ./$NVIM_DIR/bin/nvim \
    --headless \
    --noplugin \
    -u tests/init.lua \
    -c "PlenaryBustedDirectory tests/clojure-test/{{ file }} { minimal_init='tests/init.lua', sequential=true }"

run channel="stable": (prepare channel)
  ./.build/nvim/{{ channel }}/bin/nvim \
    -u tests/config.lua \
    -c "lua require(\"clojure-test.api\").run_all_tests()"
