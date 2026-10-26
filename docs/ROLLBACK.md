# Recovery / rollback

The diagnostic script makes no changes. If you only extracted files under `C:\VC2010Extract`, delete that temporary folder when finished.

If you performed an **app-local test** by adding a DLL beside `BatmanAK.exe`, close the game, confirm the added file was not part of the original installation, and remove **only that added file**. Do not delete other game files.

If you modified `C:\Windows\System32` or `C:\Windows\SysWOW64`, do not guess which file to restore. Use your pre-change backup and Windows recovery procedures or seek qualified support. Prefer an official repair process to manual replacement of shared runtime libraries.
