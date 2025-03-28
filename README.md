## solidity-http

Solidity HTTP client library for Foundry scripting

### Installation

```bash
forge install Recon-Fuzz/solidity-http
```

### Usage

### 1. Import the library

```solidity
import {HTTP} from "solidity-http/HTTP.sol";
import {HTTPBuilder} from "solidity-http/HTTPBuilder.sol";
```

### 2. Build and send your request

Use builder functions to compose your request with headers, body, and query parameters.

```solidity
contract MyScript is Script {
    using HTTPBuilder for HTTP.Request;

    HTTP.Request request;

    function run() external {
        request
            .withUrl("https://httpbin.org/post")
            .withMethod(HTTP.Method.POST)
            .withHeader("Content-Type", "application/json")
            .withBody('{"foo": "bar"}');

        HTTP.Response memory response = HTTP.request(request);

        console.log("Status:", response.status);
        console.log("Data:", response.data);
    }
}
```

### 3. Enable FFI

This library relies on Foundry's [FFI cheatcode](https://book.getfoundry.sh/cheatcodes/ffi.html) to call external processes. Enable it by:

- Passing the `--ffi` flag to your command:

```bash
forge test --ffi
```

- Or setting `ffi = true` in your `foundry.toml`:

```toml
[profile.default]
ffi = true
```

---

## Requirements

- Foundry with FFI enabled:
  - Either pass `--ffi` to commands (e.g. `forge test --ffi`)
  - Or set `ffi = true` in `foundry.toml`

```toml
[profile.default]
ffi = true
```

- A UNIX-based machine with the following installed:
  - `bash`, `curl`, `tail`, `sed`, `tr`, `cast`

### Acknowledgements

This library was inspired by [surl](https://github.com/memester-xyz/surl) and [axios](https://github.com/axios/axios)
