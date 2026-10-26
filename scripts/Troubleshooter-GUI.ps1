# Read-only Windows diagnostic launcher. Links open in browser; no silent downloads.
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()
$f=New-Object System.Windows.Forms.Form
$f.Text='Windows App & Game Troubleshooter'
$f.Size=New-Object System.Drawing.Size(920,660)
$f.StartPosition='CenterScreen'
$f.BackColor=[Drawing.Color]::FromArgb(17,24,39)
$f.ForeColor=[Drawing.Color]::White
$f.Font=New-Object Drawing.Font('Segoe UI',10)
$header=New-Object Windows.Forms.Label
$header.Text='Windows App & Game Troubleshooter'
$header.Font=New-Object Drawing.Font('Segoe UI',19,[Drawing.FontStyle]::Bold)
$header.ForeColor=[Drawing.Color]::LightSkyBlue
$header.SetBounds(20,15,850,50)
$f.Controls.Add($header)
$tabs=New-Object Windows.Forms.TabControl
$tabs.SetBounds(20,80,860,510)
$tabs.Anchor='Top,Bottom,Left,Right'
$f.Controls.Add($tabs)
function Tab([string]$name){$p=New-Object Windows.Forms.TabPage;$p.Text=$name;$p.BackColor=[Drawing.Color]::FromArgb(30,41,59);$p.ForeColor=[Drawing.Color]::White;[void]$tabs.TabPages.Add($p);return $p}
function Button($page,[string]$text,[int]$x,[int]$y,[scriptblock]$click){$b=New-Object Windows.Forms.Button;$b.Text=$text;$b.SetBounds($x,$y,395,48);$b.BackColor=[Drawing.Color]::FromArgb(51,65,85);$b.ForeColor=[Drawing.Color]::White;$b.FlatStyle='Flat';$b.Add_Click($click);$page.Controls.Add($b)}
function Label($page,[string]$text,[int]$y){$l=New-Object Windows.Forms.Label;$l.Text=$text;$l.SetBounds(20,$y,790,46);$l.ForeColor=[Drawing.Color]::LightGray;$page.Controls.Add($l)}
function OpenUrl([string]$url){try{Start-Process $url}catch{[Windows.Forms.MessageBox]::Show($_.Exception.Message,'Browser error')}}
$d=Tab 'Official downloads'
Label $d 'These buttons open official websites. Nothing is downloaded or installed automatically.' 20
$links=@(
@('Visual C++ 2015-2022','https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist'),
@('Visual C++ 2010 SP1','https://www.microsoft.com/en-us/download/details.aspx?id=26999'),
@('Visual C++ version guidance','https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist'),
@('DirectX End-User Runtime','https://www.microsoft.com/en-us/download/details.aspx?id=35'),
@('Process Monitor (Microsoft)','https://learn.microsoft.com/en-us/sysinternals/downloads/procmon'),
@('Dependencies (GitHub)','https://github.com/lucasg/Dependencies/releases'),
@('7-Zip (official)','https://www.7-zip.org/'),
@('Microsoft Windows support','https://support.microsoft.com/windows')
)
for($i=0;$i -lt $links.Count;$i++){$link=$links[$i];$x=18+($i%2)*414;$y=85+[int][math]::Floor($i/2)*73;$url=$link[1];Button $d $link[0] $x $y {OpenUrl $url}.GetNewClosure()}
Label $d 'Security: Avoid random DLL sites. Verify publishers and x86/x64 compatibility.' 408
$p=Tab 'Read-only diagnostics'
Label $p 'Inspect runtime DLL architecture and Windows version. No system files are changed.' 15
$out=New-Object Windows.Forms.TextBox
$out.Multiline=$true;$out.ScrollBars='Both';$out.WordWrap=$false;$out.ReadOnly=$true
$out.BackColor=[Drawing.Color]::FromArgb(15,23,42);$out.ForeColor=[Drawing.Color]::White
$out.Font=New-Object Drawing.Font('Consolas',9)
$out.SetBounds(18,140,800,275);$out.Anchor='Top,Bottom,Left,Right';$p.Controls.Add($out)
Button $p 'Check Visual C++ 2010 DLLs' 18 72 {try{$out.Text=(& powershell.exe -NoProfile -File (Join-Path $PSScriptRoot 'Check-VC2010Architecture.ps1') 2>&1|Out-String)}catch{$out.Text=$_.Exception.Message}}
Button $p 'Windows version / architecture' 432 72 {try{$os=Get-CimInstance Win32_OperatingSystem;$out.Text="OS: $($os.Caption)`r`nVersion: $($os.Version)`r`nArchitecture: $($os.OSArchitecture)"}catch{$out.Text=$_.Exception.Message}}
Button $p 'Copy diagnostic results' 18 425 {if($out.Text){[Windows.Forms.Clipboard]::SetText($out.Text)}}
$g=Tab 'Local guides'
Label $g 'Open the included troubleshooting guides and the documented Batman case study.' 18
$docs=@(@('Diagnostic workflow','DIAGNOSTICS.md'),@('Error codes','ERROR-CODES.md'),@('Extract verified DLLs','EXTRACTION.md'),@('Rollback and safety','ROLLBACK.md'),@('Batman case study','BATMAN-ARKHAM-KNIGHT-CASE-STUDY.md'))
for($i=0;$i -lt $docs.Count;$i++){$entry=$docs[$i];$file=Join-Path (Join-Path $PSScriptRoot '..\docs') $entry[1];Button $g $entry[0] 18 (80+$i*69) {try{Invoke-Item -LiteralPath $file}catch{[Windows.Forms.MessageBox]::Show($_.Exception.Message)}}.GetNewClosure()}
Label $g 'Case study: the DLL mismatch was confirmed; final game-launch success is not yet verified.' 438
[void]$f.ShowDialog()
