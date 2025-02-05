Clear-Host
Connect-Entra -Scopes "Device.Read.All" -ContextScope Process -NoWelcome
$lapslogo = " 
        .---------------------------------------------.
        |                                             |
        |   __         ______     ______   ______     |
        |  /\ \       /\  __ \   /\  == \ /\  ___\    |
        |  \ \ \____  \ \  __ \  \ \  _-/ \ \___  \   |
        |   \ \_____\  \ \_\ \_\  \ \_\    \/\_____\  |
        |    \/_____/   \/_/\/_/   \/_/     \/_____/  |
        |                                             |
        '---------------------------------------------'

          "
Write-Host $lapslogo -ForegroundColor Cyan
$lapsinput = Read-Host "Devicename or UPN Username"
Clear-Host
 if ($lapsinput -match "@") {
     Write-Host $lapsinput
     $entrauserdeviceid = Get-EntraUserOwnedDevice -UserId "$lapsinput" -All | Select-Object -ExpandProperty Id
     foreach ($entradevice in $entrauserdeviceid) {
        $entradevicedisplayname+= Get-EntraDevice -DeviceID "$entradevice" | Select-Object -ExpandProperty DisplayName
     }
     Out-GridView $entradevicedisplayname
 }
$lapsdeviceid = Get-entradevice -Filter "DisplayName eq '$lapsinput'" | Select-Object -ExpandProperty DeviceID
$lapspassword = Get-LapsAADPassword -DeviceIds "$lapsdeviceid" -IncludePasswords -AsPlainText | Select-Object -ExpandProperty Password
Clear-Host
Write-Host $lapslogo -ForegroundColor Cyan
Write-Host "LAPS password is: $lapspassword"
if ($lapspassword -match "[@\{\}\[\]\\]") {
     Write-Output "
     Sorry, Yubikey incompatible -__- "
     }
    else {
        $answer = Read-Host "Do you want to copy this password to a compatible Yubikey? (Yes/No)"
        if ($answer -eq "yes") {
            ykman otp static 1 -k DE -f $lapspassword
            
        }    
        else {
           Write-Output "Ok bye."
        }

            }
        