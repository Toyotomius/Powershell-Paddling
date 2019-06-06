$binaryPath = "C:\Users\DevDog\AppData\LocalLow\Temp\Microsoft\OPC\ImagingService.exe"
$serviceName = "Imaging Service"
$serviceDescription = "Imaging Service Provider"
#New-Service -name $serviceName -BinaryPathName $binaryPath -DisplayName $serviceName -Description $serviceDescription -StartupType Automatic
$serviceToRemove = Get-WmiObject -Class Win32_Service -Filter "name='$serviceName'"
$serviceToRemove.Delete()
