# Step-by-step diagnostics

## 1. Check executable and OS

Confirm that Windows is 64-bit and locate `BatmanAK.exe` (often under `Binaries\Win64`). The path varies by installation.

## 2. Inspect runtimes without changing anything

Open PowerShell and run `scripts/Check-VC2010Architecture.ps1`. On 64-bit Windows, System32 contains native 64-bit DLLs, and SysWOW64 contains 32-bit DLLs. Check all output, including `Missing` values.

## 3. Repair via official packages

Use the vendor's official redistributables and try Repair. Restart and re-run the check. If the architecture is still wrong, **do not blindly overwrite system files**. An in-place Windows repair or professional system servicing may be safer for persistent shared-runtime corruption.

## 4. Dependencies

Open the game's executable with https://github.com/lucasg/Dependencies . Record suspected DLLs and their resolved paths. Optional API-set entries and delay-loaded imports can produce false alarms. A red indicator alone is not definitive.

## 5. Process Monitor

Download https://learn.microsoft.com/en-us/sysinternals/downloads/procmon . Run as administrator. Filter by `Process Name is BatmanAK.exe`, capture a fresh launch, stop capture, then examine `Load Image` and `CreateFile` operations. Check **Path** and **Result**; many `NAME NOT FOUND` searches are expected. `CreateFile SUCCESS` proves file access, not successful image loading. If no definitive loader failure appears, consider Windows loader tracing with qualified help.

## 6. Windows Event Viewer

The following is read-only and may return no events:

```powershell
Get-WinEvent -FilterHashtable @{LogName='Application'; StartTime=(Get-Date).AddDays(-2)} -ErrorAction SilentlyContinue |
  Where-Object { $_.Message -match 'BatmanAK|0xc000007b|msvcr100|SideBySide' } |
  Select-Object -First 10 TimeCreated,Id,ProviderName,Message | Format-List
```

## 7. Report findings

Include Windows version, installer source, full error code, relevant architecture table, steps tried, and **whether the game actually launched**. Redact usernames, serials, personal paths, and tokens.
