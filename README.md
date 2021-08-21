# Use crates from this registry

Add this your `.cargo/config`:

```toml
[registries]
github_com_cschlosser = { index = "ssh://git@github.com:22/cschlosser/crate-index.git" }
```
