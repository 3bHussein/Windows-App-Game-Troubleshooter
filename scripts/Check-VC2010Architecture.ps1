# Read-only PE machine architecture checker for common VC++ 2010 runtime DLLs.
$names = @('msvcr100.dll','msvcp100.dll','mfc100.dll')
$folders = @("$env:WINDIR\System32", "$env:WINDIR\SysWOW64")
$results = foreach ($folder in $folders) {
    foreach ($name in $names) {
        $path = Join-Path $folder $name
        if (-not (Test-Path -LiteralPath $path)) {
            [pscustomobject]@{ Path=$path; Architecture='Missing'; Expected=if ($folder -like '*SysWOW64') {'x86'} else {'x64'}; Version=''; Status='Review' }
            continue
        }
        try {
            $bytes = [IO.File]::ReadAllBytes($path)
            $offset = [BitConverter]::ToInt32($bytes,0x3C)
            if ($offset -lt 0 -or $offset + 6 -gt $bytes.Length) { throw 'Invalid PE header offset' }
            $machine = [BitConverter]::ToUInt16($bytes,$offset+4)
            $arch = switch ($machine) { 0x8664 {'x64'} 0x014c {'x86'} default { 'Unknown' } }
            $expected = if ($folder -like '*SysWOW64') {'x86'} else {'x64'}
            [pscustomobject]@{ Path=$path; Architecture=$arch; Expected=$expected; Version=(Get-Item -LiteralPath $path).VersionInfo.FileVersion; Status=if ($arch -eq $expected) {'OK'} else {'MISMATCH'} }
        } catch {
            [pscustomobject]@{ Path=$path; Architecture='Unreadable'; Expected=''; Version=''; Status=$_.Exception.Message }
        }
    }
}
$results | Format-Table -AutoSize -Wrap
