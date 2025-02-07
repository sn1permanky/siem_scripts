# Запрос пароля у пользователя (если требуется)
$Password = Read-Host -AsSecureString "Введите пароль для сертификата (или оставьте пустым, чтобы не задавать пароль)"

# Преобразование SecureString в обычную строку (если пароль был введен)
if ($Password) {
    $Bypass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))
    $PasswordBytes = [System.Text.Encoding]::Unicode.GetBytes($Bypass)
    $PasswordString = ConvertTo-SecureString -String ($Bypass) -AsPlainText -Force
}

# Параметры сертификата
$DnsName = [System.Net.Dns]::GetHostEntry("localhost").HostName
$CertName = "SelfSignedCert_$DnsName" # Имя сертификата
$StartDate = Get-Date
$EndDate = $StartDate.AddYears(10) # Срок действия сертификата (10 лет)

# Создание самоподписанного сертификата
$Certificate = New-SelfSignedCertificate -DnsName $DnsName -CertStoreLocation Cert:\LocalMachine\My -FriendlyName $CertName -NotAfter $EndDate -KeyAlgorithm "RSA" -KeyLength 2048

# Экспорт сертификата в формате PFX (PKCS #12) с паролем (если был введен)
if ($Password) {
    Export-PfxCertificate -Cert $Certificate -FilePath "$CertName.pfx" -Password $PasswordString
    Write-Host "Сертификат экспортирован в файл: $CertName.pfx с паролем."
} else {
    Export-PfxCertificate -Cert $Certificate -FilePath "$CertName.pfx" -Password $null
    Write-Host "Сертификат экспортирован в файл: $CertName.pfx без пароля."
}

Write-Host "Сертификат создан и установлен в хранилище 'LocalMachine\My'."
Write-Host "Имя сертификата: $CertName"
Write-Host "Отпечаток сертификата: $($Certificate.Thumbprint)"
