# OpenWrt ucode Package Template

A modern, battery-included template for developing [ucode](https://openwrt.org/docs/guide-developer/ucode) packages with optional C extensions.

## 🚀 Using this Template

1. Click the **"Use this template"** button on GitHub to create your own repository.
2. Clone your new repository locally.
3. Run the setup script to customize the package name and maintainer info:

    ```bash
    ./setup.sh
    ```

4. Start developing!

---

## Features

- **Mixed Codebase:** Seamlessly mix `ucode` scripts and C extensions.
- **Modern Build:** Uses **CMake** for C compilation (industry standard).
- **Isolated Development:** Fully Dockerized SDK environment. No host pollution.
- **Unit Testing:** Integrated test runner for instant feedback.
- **Auto-Reload:** `make -f dev.mk watch-tests` recompiles C and runs tests on every save.
- **LSP Support:** Syncs SDK headers to your editor for autocompletion.
- **CI/CD:** GitHub Actions for testing, IPK building, and Docker caching.

## Project Structure

- `src/`: **Compiled Sources.** C code (`.c`) and `CMakeLists.txt`.
- `files/`: **Static Files.** ucode scripts and config files (e.g., `files/usr/share/ucode/myapp.uc`).
- `test/`: **Tests.** Unit tests run against the code in `src` and `files`.
- `Makefile`: Standard OpenWrt package definition.
- `dev.mk`: Developer task runner (local builds, tests, debugging).

## Getting Started

### 1. Prerequisites

- Docker
- Make
- [entr](https://eradman.com/entrproject/) (for `watch-tests` mode)

### 2. Development

Build the development environment (only needed once or after `setup.sh`):

```bash
make -f dev.mk prepare
```

Run tests (compiles C code automatically):

```bash
make -f dev.mk test
```

Watch mode (Auto-rebuild & test):

```bash
make -f dev.mk watch-tests
```

*(Requires `entr` to be installed on your host)*

### 3. Debugging

Drop into a shell inside the container with all tools loaded:

```bash
make -f dev.mk debug
```

### 4. Building the IPK

To build the final package for OpenWrt (defaults to x86-64):

```bash
make -f dev.mk package
```

The resulting `.ipk` will be in the `bin/` directory.

## Development Workflow

1. **Initialize**: Run `./setup.sh` to rename the template.
2. **Code**: Edit `.uc` files in `files/` or `.c` files in `src/`.
3. **Watch**: Run `make -f dev.mk watch-tests` in a terminal.
    - It detects changes.
    - Recompiles C code (incrementally).
    - Runs unit tests.
4. **Release**: Run `make -f dev.mk package` to get the artifact.

## Troubleshooting

**"Volume persistence" or missing headers:**
If your editor complains about missing headers, run:

```bash
make -f dev.mk sync-headers
```

This copies the SDK headers to `.include/` for `clangd`/LSP.

**Build failures in Docker:**
Try cleaning the local artifacts:

```bash
make -f dev.mk clean
```

## Multi-Architecture

By default, this template builds for `x86-64`. To target a specific router (e.g., Raspberry Pi 4), you can override the target architecture and SDK version:

```bash
# Example: Build for Raspberry Pi 4
make -f dev.mk package SDK_ARCH=bcm2711-64 SDK_VERSION=23.05.5
```

**How to find your architecture:**
1.  Go to the [OpenWrt Firmware Selector](https://firmware-selector.openwrt.org/).
2.  Search for your device.
3.  The "Target" field (e.g., `ipq60xx/generic`) is your `SDK_ARCH` (replace the slash with a hyphen: `ipq60xx-generic`).

**Testing on other architectures:**
You can even run your unit tests against different architectures using QEMU emulation (automatic):
```bash
make -f dev.mk test SDK_ARCH=aarch64_cortex-a53
```
*Note: The first run for a new architecture will download a ~1.5GB SDK image.*

## Dependency Management

Dependencies are defined in `Makefile`.

```makefile
DEPENDS:=+ucode +libucode +ucode-mod-fs ...
```

Only include the modules you actually use (`fs`, `ubus`, `uci`, etc.) to keep the package size small.

## Testing Framework

This template includes a custom test framework (`test/testing.uc`) with:

- `test(name, fn)` - Register a test
- `assert(condition, msg)` - Assert truth
- `assert_eq(actual, expected, msg)` - Deep equality check
- `assert_throws(fn, msg)` - Expect exceptions

Tests are automatically discovered in `test/unit/*_test.uc` and run in random order.

Run with: `make -f dev.mk test VERBOSE=1`

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
