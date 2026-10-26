# Common Windows launch errors

These codes are starting points, not definitive diagnoses.

| Code | Common meaning | Next check |
|---|---|---|
| `0xc000007b` | Invalid image format | Check x86/x64 DLL mismatch, official runtimes, and module-load traces |
| `0xc0000142` | DLL initialization failure | Check Event Viewer and dependency initialization |
| `0xc0000135` | Missing DLL/dependency | Identify missing runtime; install from vendor |
| `0xc0000005` | Access violation | Check crash logs, drivers, overlays, and application integrity |

See [DIAGNOSTICS.md](DIAGNOSTICS.md) for evidence-based investigation. Do not assume the error code identifies a specific DLL.
