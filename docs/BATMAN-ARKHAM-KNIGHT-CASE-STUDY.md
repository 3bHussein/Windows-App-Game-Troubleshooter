# Case study: Windows 10 Pro 64-bit

**Date:** October 26, 2026. **Status:** Diagnosis ongoing; final successful launch not confirmed.

1. `BatmanAK.exe` displayed `0xc000007b`.
2. Attempting to install a v14 Visual C++ package displayed `0x80070666`: another version was already installed. This was a separate installer issue, not proof of the game's root cause.
3. Dependencies flagged `MSVCR100.dll`; such warnings are clues, not conclusive proof.
4. PowerShell PE-header inspection showed `System32\msvcr100.dll` as x86. Later inspection showed `SysWOW64\msvcp100.dll` as x64. These are wrong for the corresponding folders on 64-bit Windows.
5. Visual C++ 2010 repair/reinstall attempts did not fix those files.
6. Application event log searches returned no matching events; absence of events does not exclude a loader error.
7. Process Monitor captured `BatmanAK.exe` activity. `CreateFile SUCCESS` was observed for the System32 runtime, but that does not prove successful loading. The displayed `Load Image` events did not conclusively identify the failing DLL.
8. The official `vcredist_x64.exe` was verified as Microsoft-signed. An administrative MSI extraction (`msiexec /a`) failed with 1603. The detailed log identified **Error 1308**, missing `install.res.2052.dll`; therefore this failure was caused by incomplete extraction of supporting installer files.
9. Opening the embedded `vc_red.cab` in 7-Zip exposed `F_CENTRAL_msvcr100_x64`. Extracted file: x64, 829,264 bytes, Microsoft Authenticode signature Valid, SHA256 `1D1A1AE540BA132F998D60D3622F0297B6E86AE399332C3B47462D7C0F560A36` (case-specific; not an independently maintained reference hash).
10. The extracted file was copied to a separate staging directory as `msvcr100.dll`; its signature remained Valid.
11. The game executable was found at `C:\Games\Batman - Arkham Knight\Binaries\Win64\BatmanAK.exe`. No `msvcr100.dll` existed beside it. A reversible game-directory test was proposed. **No result was reported yet.**

## Conclusions

Two runtime DLLs were in wrong architecture folders. The 0xc000007b error is consistent with this class of problem, but the exact loader failure and the effectiveness of the proposed game-local workaround remain unverified. Do not label this a guaranteed fix.
