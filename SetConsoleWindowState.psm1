<#

.Synopsis
   Set the Window State of the Powershell Console Window

.DESCRIPTION
   Enables PowerShell scripts to set the visibility and various states of the PowerShell Console Window

.EXAMPLE
   Set-ConsoleWindowState -WindowState Minimized

.NOTES
   Author: Richard Bunker
   Version History:-
   1.0 - 08/06/2016 - Richard Bunker - Initial Version

.FUNCTIONALITY
   Enables PowerShell scripts to hide and set the various window states of the PowerShell console

#>

$DebugPreference="SilentlyContinue"

$script:showWindowAsync=Add-Type -MemberDefinition @"
[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
"@ -Name "Win32ShowWindowAsync" -Namespace Win32Functions -PassThru

Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    public class SetWindowToFront {
        [DllImport("user32.dll")]
        [return: MarshalAs(UnmanagedType.Bool)]
        public static extern bool SetForegroundWindow(IntPtr hWnd);
    }
"@

function Set-ConsoleWindowState {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateSet("Normal", "Maximized","Minimized","Default","Hidden","SetWindowToFront")]
        [String]
        $WindowState="Normal"
    )

    switch ($WindowState)
    {
        'Normal' {$null = $script:showWindowAsync::ShowWindowAsync((Get-Process -id $pid).MainWindowHandle, 1)}
        'Maximized' {$null = $script:showWindowAsync::ShowWindowAsync((Get-Process -id $pid).MainWindowHandle, 3)}
        'Minimized' {$null = $script:showWindowAsync::ShowWindowAsync((Get-Process -id $pid).MainWindowHandle, 2)}
        'Default' {$script:showWindowAsync::ShowWindowAsync((Get-Process -id $pid).MainWindowHandle, 10)}
        'Hidden' {$null = $script:showWindowAsync::ShowWindowAsync((Get-Process -id $pid).MainWindowHandle, 0)}
        'SetWindowToFront' {[void][SetWindowToFront]::SetForegroundWindow((Get-Process -id $pid).MainWindowHandle)}
    }

}

# Export Module Functions:
Export-ModuleMember -Function Set-ConsoleWindowState