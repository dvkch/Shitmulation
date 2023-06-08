# Vendor tools

- original: <https://github.com/pelotoncycle/bsort>
- parallelized: <https://github.com/pelotoncycle/bsort>

    ```
    brew install cmake libomp
    set -x -g LDFLAGS "-L/opt/homebrew/opt/libomp/lib"
    set -x -g CFLAGS "-I/opt/homebrew/opt/libomp/include"
    set -x -g CPPFLAGS "-I/opt/homebrew/opt/libomp/include"
    set -x -g CXXFLAGS "-I/opt/homebrew/opt/libomp/include"
    cmake .
    make
    ```

Turns out, the parallelized version doesn't work and sorts badly when using multiple threads... so we'll only use the original one.
