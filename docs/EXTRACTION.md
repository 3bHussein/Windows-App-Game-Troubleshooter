# Extracting original files for inspection (advanced)

Only use authentic redistributables downloaded from Microsoft. Confirm signature:

```powershell
Get-AuthenticodeSignature "$env:USERPROFILE\Downloads\vcredist_x64.exe" | Select-Object Status,SignerCertificate
```

The 2010 SP1 EXE can contain `vc_red.msi`, `vc_red.cab`, and patch/language resources. Open the EXE with 7-Zip, inspect the embedded CAB, and extract `F_CENTRAL_msvcr100_x64` **to a staging folder**, not a Windows folder. Its CAB entry may lack a `.dll` extension; inspect its PE header before renaming a staging copy.

Example for a staged file:

```powershell
$p = 'C:\VC2010Extract\Fixed\F_CENTRAL_msvcr100_x64'
$b = [IO.File]::ReadAllBytes($p)
$o = [BitConverter]::ToInt32($b,0x3c)
'{0:X4}' -f [BitConverter]::ToUInt16($b,$o+4)
Get-AuthenticodeSignature $p | Select-Object Status
```

`8664` = x64, `014C` = x86. A valid signature plus expected architecture is useful evidence. Do not infer that every version must have the same size or SHA256 hash as this case.

**Installer extraction pitfall:** `msiexec /a` may return error 1603 if MSI companion files are missing. Read the verbose log around `Return value 3`; in the documented case the underlying cause was error 1308, missing `install.res.2052.dll`. This is not a general repair procedure.

**Important:** This guide intentionally does not include commands to replace protected Windows DLLs. For a local application-only test, back up any existing app-local file and use only verified vendor-provided binaries; app-local DLL loading is application-dependent and is not guaranteed to solve 0xc000007b.
