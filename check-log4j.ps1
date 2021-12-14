param (
    [Parameter (Mandatory=$true)][String]$logfile,
    [Switch]$DeepScan,
    [String]$hosts,
    [String]$retryFile
)

$computerNames = if ($hosts -ne "") {
    try {
        Import-Csv $hosts
    }
    catch {
        echo "Error importing `"$hosts`""
        Write-Debug $_
        exit 1
    }
} else {
    @(get-adcomputer -Filter { OperatingSystem -Like '*Windows Server*' } | Select name )
}


$ignoreDrives = @("A", "B" )



If ($retryFile -ne "" -and (Test-Path $retryFile)) {
    $computerNames = Import-Csv $retryFile
    echo '#TYPE Selected.Microsoft.ActiveDirectory.Management.ADComputer' > $retryFile
    echo '"name"' >> $retryFile
} elseif ($retryFile -ne "" -and -not (Test-Path $retryFile)) {
    echo '#TYPE Selected.Microsoft.ActiveDirectory.Management.ADComputer' > $retryFile
    echo '"name"' >> $retryFile
}



try {
    Start-Transcript -Path $logfile -NoClobber
} catch {
    if ( $retryFile -ne "") {
        rm $retryFile
    }
    echo "Error Starting transcript"
    echo ""
    echo "Please remove old log before running this script again"
    Write-Debug $_
    exit 1
}
echo "Logging to `"$logfile`" started"


if ( $DeepScan ) {
    $keyword = "*.jar"
    foreach ($computer in $computerNames) {
        $ComputerName = $computer.name
        if ((Test-Connection -computername $ComputerName -Quiet) -eq $true) {
            echo "$ComputerName (Online)"
            try {
                Invoke-Command -ComputerName $ComputerName -ScriptBlock {
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
            catch {
                echo Error
                If ($retryFile -ne $null) {
                    echo "`"$ComputerName`"" >> $retryFile
                }
            }
        }
        else{            
            "$ComputerName (Unavailable)"
            If ($retryFile -ne $null) {
                echo "`"$ComputerName`"" >> $retryFile
            }
        }
    }
}
else {
    $keyword = "*log4j*.jar"
    foreach ($computer in $computerNames) {
        $ComputerName = $computer.name
        if ((Test-Connection -computername $ComputerName -Quiet) -eq $true) {
            echo "$ComputerName (Online)"
            try {
                Invoke-Command -ComputerName $ComputerName -ScriptBlock {
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
            catch {
                If ($retryFile -ne $null) {
                    echo "`"$ComputerName`"" >> $retryFile
                }
            }
            echo ""
        }
        else{            
            "$ComputerName (Unavailable)"
            If ($retryFile -ne $null) {
                echo "`"$ComputerName`"" >> $retryFile
            }
        }
    }
}
Stop-Transcript

<#

This is a quick script, don't expect it to be too neat.
It should work for it's intended purpose, readability may be a bit harsh.

#>
