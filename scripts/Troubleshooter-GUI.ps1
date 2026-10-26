# Guided Windows App & Game Troubleshooter - PowerShell 5.1 / Windows Forms
# Read-only checks. External resources open in default browser.
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[Windows.Forms.Application]::EnableVisualStyles()
$bg=[Drawing.Color]::FromArgb(12,18,22)
$panel=[Drawing.Color]::FromArgb(22,31,36)
$green=[Drawing.Color]::FromArgb(89,232,152)
$muted=[Drawing.Color]::FromArgb(163,184,184)
$white=[Drawing.Color]::FromArgb(233,244,239)
$form=New-Object Windows.Forms.Form
$form.Text='Terminal Tools | Guided Troubleshooter'
$form.Size=New-Object Drawing.Size(1010,735)
$form.MinimumSize=New-Object Drawing.Size(940,680)
$form.StartPosition='CenterScreen'
$form.BackColor=$bg
$form.ForeColor=$white
$form.Font=New-Object Drawing.Font('Segoe UI',10)
function Label($parent,$text,$x,$y,$w,$h,$color=$muted,$size=10){
 $c=New-Object Windows.Forms.Label
 $c.Text=$text; $c.SetBounds($x,$y,$w,$h); $c.ForeColor=$color
 $c.Font=New-Object Drawing.Font('Segoe UI',$size)
 $parent.Controls.Add($c); return $c
}
function Button($parent,$text,$x,$y,$w,$h,$action){
 $c=New-Object Windows.Forms.Button
 $c.Text=$text; $c.SetBounds($x,$y,$w,$h)
 $c.FlatStyle='Flat'; $c.FlatAppearance.BorderColor=$green
 $c.BackColor=$panel; $c.ForeColor=$white; $c.Cursor='Hand'
 $c.Add_Click($action); $parent.Controls.Add($c); return $c
}
function OpenUrl($url){
 try { Start-Process $url } catch { [Windows.Forms.MessageBox]::Show($_.Exception.Message,'Unable to open link') | Out-Null }
}
$header=New-Object Windows.Forms.Panel
$header.SetBounds(0,0,1010,82); $header.BackColor=$panel
$header.Anchor='Top,Left,Right'; $form.Controls.Add($header)
[void](Label $header '>_ TERMINAL TOOLS' 24 9 740 38 $green 20)
[void](Label $header 'GUIDED MODE  /  WINDOWS 10 + 11  /  NO AUTOMATIC REPAIRS' 27 50 860 22 $muted 9)
$stepTitle=Label $form '' 28 104 920 42 $green 18
$progress=Label $form '' 30 149 910 27 $muted 10
$content=New-Object Windows.Forms.Panel
$content.SetBounds(28,185,936,400); $content.BackColor=$panel
$content.Anchor='Top,Bottom,Left,Right'; $form.Controls.Add($content)
$back=Button $form '< Back' 30 606 150 46 { ChangeStep ($script:step-1) }
$next=Button $form 'Next >' 782 606 180 46 { ChangeStep ($script:step+1) }
$next.Anchor='Bottom,Right'; $back.Anchor='Bottom,Left'
$footer=Label $form '[SAFE] READ-ONLY  |  DOWNLOADS OPEN OFFICIAL SITES  |  NO SYSTEM FILE CHANGES' 30 666 925 26 $green 9
$footer.Anchor='Bottom,Left'
$script:step=0
$script:issue='0xc000007b'
$script:appName=''
$script:report=''
$script:status=''
function ClearPanel(){ $content.Controls.Clear() }
function Guidance(){
 switch($script:issue){
  '0xc000007b' { return @('Possible 32-bit/64-bit runtime mismatch.','1. Check whether the app is x86 or x64.','2. Inspect installed Visual C++ runtimes.','3. Use the official VC++ installer matching the app.','4. If it still fails, use Dependencies and collect evidence.') }
  '0xc0000135' { return @('A required runtime or framework may be missing.','1. Note the exact missing component from the error.','2. Check the application requirements.','3. Install the required .NET or VC++ runtime from Microsoft.','4. Retry the application and capture the exact error.') }
  '0xc0000142' { return @('Application initialization failed; multiple causes are possible.','1. Restart and test the app once.','2. Verify app files using its installer or launcher.','3. Review Event Viewer application errors.','4. Check third-party overlays and compatibility settings.') }
  'Missing DLL' { return @('A DLL may be missing or not found by the app.','1. Write down the exact DLL filename.','2. Check the app vendor requirements and installer.','3. Install the official runtime if the DLL belongs to one.','4. Do not copy random DLL files into Windows folders.') }
  'Crash / no window' { return @('Silent exits require more evidence before choosing a fix.','1. Confirm app files and minimum system requirements.','2. Look for a Windows Event Viewer application error.','3. Check antivirus quarantine and vendor logs.','4. Capture the failing module with Process Monitor if needed.') }
  default { return @('Follow the vendor troubleshooting instructions.','1. Record the full error message.','2. Check Event Viewer and app logs.','3. Check required runtimes and architecture.','4. Do not change system DLLs without evidence.') }
 }
}
function ChangeStep([int]$n){
 if($n -lt 0 -or $n -gt 3){return}
 $script:step=$n
 ClearPanel
 $back.Enabled=($n -gt 0)
 $next.Visible=($n -lt 3)
 $progress.Text="STEP $($n+1) OF 4     " + ('[ '+('=' * ($n+1))+(' -' * (3-$n))+' ]')
 switch($n){
  0 {
   $stepTitle.Text='01  Tell us what is happening'
   [void](Label $content 'Select the error you see, then enter the game or app name (optional).' 22 23 865 42 $white 12)
   [void](Label $content 'ERROR TYPE' 22 88 500 24 $green 10)
   $script:issueCombo=New-Object Windows.Forms.ComboBox
   $script:issueCombo.SetBounds(22,118,660,38); $script:issueCombo.DropDownStyle='DropDownList'
   $script:issueCombo.Font=New-Object Drawing.Font('Segoe UI',12)
   [void]$script:issueCombo.Items.AddRange([object[]]@('0xc000007b','0xc0000135','0xc0000142','Missing DLL','Crash / no window','Other error'))
   $script:issueCombo.SelectedItem=$script:issue
   $script:issueCombo.Add_SelectedIndexChanged({$script:issue=[string]$script:issueCombo.SelectedItem})
   $content.Controls.Add($script:issueCombo)
   [void](Label $content 'GAME / APP NAME (OPTIONAL)' 22 187 500 25 $green 10)
   $script:appNameInput=New-Object Windows.Forms.TextBox
   $script:appNameInput.SetBounds(22,217,660,35); $script:appNameInput.Text=$script:appName
   $script:appNameInput.Font=New-Object Drawing.Font('Segoe UI',12)
   $script:appNameInput.Add_TextChanged({$script:appName=$script:appNameInput.Text})
   $content.Controls.Add($script:appNameInput)
   [void](Label $content 'No installation or administrator permission required.' 22 292 840 50 $muted 11)
  }
  1 {
   $stepTitle.Text='02  Check your Windows environment'
   [void](Label $content 'Optional read-only checks. Choose a check, or go to the next step.' 22 20 875 36 $white 12)
   $script:diagnosticsOutput=New-Object Windows.Forms.TextBox
   $script:diagnosticsOutput.SetBounds(22,132,884,240); $script:diagnosticsOutput.Multiline=$true; $script:diagnosticsOutput.ReadOnly=$true
   $script:diagnosticsOutput.ScrollBars='Both'; $script:diagnosticsOutput.WordWrap=$false
   $script:diagnosticsOutput.BackColor=$bg; $script:diagnosticsOutput.ForeColor=$green
   $script:diagnosticsOutput.Font=New-Object Drawing.Font('Consolas',10)
   $script:diagnosticsOutput.Text=if($script:report){$script:report}else{'Ready. Choose a check above.'}
   $script:diagnosticsOutput.Anchor='Top,Bottom,Left,Right'; $content.Controls.Add($script:diagnosticsOutput)
   [void](Button $content 'Check Windows' 22 70 260 46 {
     try {
      $os=Get-CimInstance Win32_OperatingSystem
      $script:report="Windows: $($os.Caption)`r`nVersion: $($os.Version)`r`nArchitecture: $($os.OSArchitecture)"
     } catch { $script:report=$_.Exception.Message }
     $script:diagnosticsOutput.Text=$script:report
   })
   [void](Button $content 'Check VC++ 2010 DLLs' 302 70 310 46 {
     try {
      $checker=Join-Path $PSScriptRoot 'Check-VC2010Architecture.ps1'
      $script:report=(& $checker 2>&1 | Out-String)
     } catch { $script:report=$_.Exception.Message }
     $script:diagnosticsOutput.Text=$script:report
   })
   [void](Button $content 'Copy results' 633 70 273 46 {
     if($script:diagnosticsOutput.Text){[Windows.Forms.Clipboard]::SetText($script:diagnosticsOutput.Text)}
   })
  }
  2 {
   $stepTitle.Text='03  Follow the recommended actions'
   $items=Guidance
   $y=18
   foreach($item in $items){
    [void](Label $content $item 22 $y 872 52 $(if($y -eq 18){$green}else{$white}) 11)
    $y+=64
   }
   [void](Label $content 'Only download software from the official publisher. Avoid random DLL sites.' 22 344 865 35 $muted 10)
  }
  3 {
   $stepTitle.Text='04  Resources and next steps'
   [void](Label $content "Selected issue: $($script:issue)     App: $($script:appName)" 22 15 890 34 $white 11)
   [void](Label $content 'Open official sources as needed. Installers never run automatically.' 22 52 865 34 $muted 10)
   $resources=@(
    @('Microsoft Visual C++ redistributables','https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist'),
    @('Visual C++ 2010 SP1','https://www.microsoft.com/en-us/download/details.aspx?id=26999'),
    @('Microsoft DirectX Runtime','https://www.microsoft.com/en-us/download/details.aspx?id=35'),
    @('Process Monitor - Microsoft','https://learn.microsoft.com/en-us/sysinternals/downloads/procmon'),
    @('Dependencies - GitHub releases','https://github.com/lucasg/Dependencies/releases'),
    @('7-Zip - official site','https://www.7-zip.org/')
   )
   for($i=0;$i -lt $resources.Count;$i++){
    $url=$resources[$i][1]
    $x=22+(($i%2)*450); $y=97+([math]::Floor($i/2)*66)
    [void](Button $content $resources[$i][0] $x $y 430 49 {OpenUrl $url}.GetNewClosure())
   }
   [void](Button $content 'Copy summary' 22 307 280 49 {
    $summary="App: $($script:appName)`r`nError: $($script:issue)`r`n`r`nSuggested steps:`r`n"+((Guidance) -join "`r`n")+"`r`n`r`nDiagnostics:`r`n$($script:report)"
    [Windows.Forms.Clipboard]::SetText($summary)
    [Windows.Forms.MessageBox]::Show('Summary copied to clipboard.','Done') | Out-Null
   })
   [void](Button $content 'Start again' 326 307 280 49 {
    $script:report=''; $script:issue='0xc000007b'; $script:appName=''
    ChangeStep 0
   })
  }
 }
}
ChangeStep 0
[void][Windows.Forms.Application]::Run($form)
