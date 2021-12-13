param (
    [Parameter (Mandatory=$true)][String]$logfile,
    [Switch]$DeepScan
)
$computerNames = @(get-adcomputer -Filter { OperatingSystem -Like '*Windows Server*' } | Select name )
$ignoreDrives = @("A", "B" )


If ( (test-path $logfile) ) {
    try {
        rm $logfile
    } catch {
        exit 1
    }
}

Start-Transcript -Path $logfile -NoClobber

if ( $DeepScan ) {
    $keyword = "*.jar"
    foreach ($computer in $computerNames) {
        $computer.name # Show computername
        if ((Test-Connection -computername $computer.name -Quiet) -eq $true) {
            Invoke-Command -ComputerName $computer.name -ScriptBlock {
                $drives = Get-PSDrive -PSProvider FileSystem
                $jars = @()
                foreach ($drive in $drives) {
                    if ($drive.Name -notin $using:ignoreDrives) {
                        $items = Get-ChildItem -Path $drive.Root -Filter $using:keyword -ErrorAction SilentlyContinue -File -Recurse
                        foreach ($item in $items) {
                            $jars += $item.FullName
                        }
                    }
                }
                if ( $jars[0] -eq $null ) {
                    echo "No jars were found"
                } else {
                    
                    $log4jjars = $JARs | Select-String -SimpleMatch "log4j"
                    
                    if ( $log4jjars -eq $null ) {
                    
                        echo "No log4j-Files were found, but it might be integrated in one of the following jars:"
                        $jars
                    } else {
                        echo "The following log4js-Files were found:"
                        foreach ( $file in $log4jjars ) {
                            echo "$file"
                        }
                    }
                }
                echo ""
            }
        }
        else{
         "$computer (Unavailable)"
        }
    }
}
else {
    $keyword = "*log4j*.jar"
    foreach ($computer in $computerNames) {
        $computer.name # Show computername
        if ((Test-Connection -computername $computer.name -Quiet) -eq $true) {
            Invoke-Command -ComputerName $computer.name -ScriptBlock {
                $drives = Get-PSDrive -PSProvider FileSystem
                foreach ($drive in $drives) {
                    if ($drive.Name -notin $using:ignoreDrives) {
                        $items = Get-ChildItem -Path $drive.Root -Filter $using:keyword -ErrorAction SilentlyContinue -File -Recurse
                        foreach ($item in $items) {
                            $item.FullName # Show all files found with full drive and path
                        }
                    }
                }
            }
        }
        else{
         "$computer (Unavailable)"
        }
    }
}
Stop-Transcript

<#

This is a quick script, don't expect it to be too neat.
It should work for it's intended purpose, readability may be a bit harsh.

#>

