FROM mcr.microsoft.com/windows/servercore:1809

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue'; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]'Tls12,Tls11,Tls'; "]

RUN \
    # Download log collection utility
    Invoke-WebRequest -Uri https://aka.ms/vscollect.exe -OutFile C:\collect.exe; \
    # Note: Add .NET + ASP.NET
    Install-WindowsFeature NET-Framework-45-ASPNET ; \
    Install-WindowsFeature Web-Asp-Net45; \
    # Download NuGardt v4.5.0
    New-Item -Path C:\nuget -Type Directory | Out-Null; \
    [System.Environment]::SetEnvironmentVariable('PATH', "\"${env:PATH};C:\nuget\"", 'Machine'); \
    Invoke-WebRequest -Uri "https://dist.nuget.org/win-x86-commandline/v4.5.0/nuget.exe" -OutFile C:\nuget\nuget.exe; \
    # Download and install .Net 4.5.2 Developer Pack
    Invoke-WebRequest "https://download.microsoft.com/download/4/3/B/43B61315-B2CE-4F5B-9E32-34CCA07B2F0E/NDP452-KB2901951-x86-x64-DevPack.exe" -OutFile "$env:TEMP\NDP452-KB2901951-x86-x64-DevPack.exe" -UseBasicParsing; \
    $p = Start-Process -Wait -PassThru -FilePath "$env:TEMP\NDP452-KB2901951-x86-x64-DevPack.exe" -ArgumentList "/install","/quiet"; \
    if ($ret = $p.ExitCode) { c:\collect.exe; throw ('Install failed with exit code 0x{0:x}' -f $ret) }; \
    rm "$env:TEMP\NDP452-KB2901951-x86-x64-DevPack.exe"; \
    # Download and install .Net 4.6.2 Developer Pack
    Invoke-WebRequest "https://download.microsoft.com/download/E/F/D/EFD52638-B804-4865-BB57-47F4B9C80269/NDP462-DevPack-KB3151934-ENU.exe" -OutFile "$env:TEMP\NDP462-DevPack-KB3151934-ENU.exe" -UseBasicParsing; \
    $p = Start-Process -Wait -PassThru -FilePath "$env:TEMP\NDP462-DevPack-KB3151934-ENU.exe" -ArgumentList "/install","/quiet"; \
    if ($ret = $p.ExitCode) { c:\collect.exe; throw ('Install failed with exit code 0x{0:x}' -f $ret) }; \
    rm "$env:TEMP\NDP462-DevPack-KB3151934-ENU.exe"; \
    # Download and install Web Deploy v3.6
    Invoke-WebRequest "https://download.microsoft.com/download/0/1/D/01DC28EA-638C-4A22-A57B-4CEF97755C6C/WebDeploy_amd64_en-US.msi" -OutFile "$env:TEMP\WebDeploy_amd64_en-US.msi" -UseBasicParsing; \
    $p = Start-Process -Wait -PassThru -FilePath "msiexec" -ArgumentList """/i ""$env:TEMP\WebDeploy_amd64_en-US.msi"" /quiet"""; \
    if ($ret = $p.ExitCode) { c:\collect.exe; throw ('Install failed with exit code 0x{0:x}' -f $ret) }; \
    rm "$env:TEMP\WebDeploy_amd64_en-US.msi"; \
    # Download and install .Net Core v1.1.7 SDK
    Invoke-WebRequest "https://download.microsoft.com/download/4/E/6/4E64A465-F02E-43AD-9A86-A08A223A82C3/dotnet-dev-win-x64.1.1.7.exe" -OutFile "$env:TEMP\dotnet-dev-win-x64.1.1.7.exe" -UseBasicParsing; \
    $p = Start-Process -Wait -PassThru -FilePath "$env:TEMP\dotnet-dev-win-x64.1.1.7.exe" -ArgumentList "/install","/quiet"; \
    if ($ret = $p.ExitCode) { c:\collect.exe; throw ('Install failed with exit code 0x{0:x}' -f $ret) }; \
    rm "$env:TEMP\dotnet-dev-win-x64.1.1.7.exe"; \
    # Download and install .Net Core v2.1.4 SDK
    Invoke-WebRequest "https://download.microsoft.com/download/1/1/5/115B762D-2B41-4AF3-9A63-92D9680B9409/dotnet-sdk-2.1.4-win-x64.exe" -OutFile "$env:TEMP\dotnet-sdk-2.1.4-win-x64.exe" -UseBasicParsing; \
    $p = Start-Process -Wait -PassThru -FilePath "$env:TEMP\dotnet-sdk-2.1.4-win-x64.exe" -ArgumentList "/install","/quiet"; \
    if ($ret = $p.ExitCode) { c:\collect.exe; throw ('Install failed with exit code 0x{0:x}' -f $ret) }; \
    rm "$env:TEMP\dotnet-sdk-2.1.4-win-x64.exe"; \
    Invoke-WebRequest -Uri "https://download.microsoft.com/download/9/B/B/9BB1309E-1A8F-4A47-A6C5-ECF76672A3B3/BuildTools_Full.exe" -OutFile $env:TEMP\BuildTools_Full.exe; \
    $p = Start-Process -Wait -PassThru -FilePath $env:TEMP\BuildTools_Full.exe -ArgumentList '/Silent /Full'; \
    if ($ret = $p.ExitCode) { c:\collect.exe; throw ('Install failed with exit code 0x{0:x}' -f $ret) }; \
    rm "$env:TEMP\BuildTools_Full.exe"; \
    #Set PATH variable
    $env:PATH = 'C:\Program Files (x86)\MSBuild\12.0\Bin\;C:\nuget\;' + $env:PATH; \
    [Environment]::SetEnvironmentVariable('PATH', $env:PATH, [EnvironmentVariableTarget]::Machine); \
    # Get Web Targets and move them
    New-Item -ItemType directory -Path 'C:\Program Files (x86)\MSBuild\Microsoft\VisualStudio\v12.0\'; \
    "C:\nuget\nuget.exe" Install MSBuild.Microsoft.VisualStudio.Web.targets -Version 12.0.4; \
    mv 'C:\MSBuild.Microsoft.VisualStudio.Web.targets.12.0.4\tools\VSToolsPath\*' 'C:\Program Files (x86)\MSBuild\Microsoft\VisualStudio\v12.0\';
