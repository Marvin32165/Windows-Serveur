# Fix-ADDnsRecords.ps1
# Répare la config de base des zones AD DNS et force la réinscription des records AD/SRV

[CmdletBinding()]
param(
    [switch]$CreateMissingZones = $true,
    [string]$LogPath = "C:\Temp\Fix-ADDnsRecords.log"
)

$ErrorActionPreference = "Stop"

function Write-Log {
    param([string]$Message)
    $line = "[{0}] {1}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Message
    Write-Host $line
    Add-Content -Path $LogPath -Value $line
}

function Ensure-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p  = New-Object Security.Principal.WindowsPrincipal($id)
    if (-not $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "Ce script doit être lancé en PowerShell 'Exécuter en tant qu'administrateur'."
    }
}

function Ensure-Folder {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -ItemType Directory -Force | Out-Null
    }
}

Ensure-Folder -Path ([System.IO.Path]::GetDirectoryName($LogPath))
Start-Transcript -Path ($LogPath -replace '\.log$', '.transcript.txt') -Force | Out-Null

try {
    Ensure-Admin

    Import-Module ActiveDirectory -ErrorAction Stop
    Import-Module DnsServer -ErrorAction Stop

    $computer = $env:COMPUTERNAME
    $cs = Get-CimInstance Win32_ComputerSystem
    if (-not $cs.PartOfDomain) {
        throw "La machine n'est pas jointe au domaine."
    }

    $dc = Get-ADDomainController -Identity $computer -ErrorAction Stop
    $domain = Get-ADDomain
    $forest = Get-ADForest

    $domainFqdn = $domain.DNSRoot
    $forestRoot = $forest.RootDomain
    $msdcsZone  = "_msdcs.$forestRoot"

    Write-Log "Serveur : $computer"
    Write-Log "Domaine : $domainFqdn"
    Write-Log "Forêt   : $forestRoot"
    Write-Log "Zone _msdcs attendue : $msdcsZone"

    # Vérifie la présence du rôle DNS
    $dnsService = Get-Service -Name DNS -ErrorAction SilentlyContinue
    if (-not $dnsService) {
        throw "Le service DNS n'est pas installé sur ce serveur."
    }

    # 1) Vérifier / créer les zones si besoin
    $existingDomainZone = Get-DnsServerZone -Name $domainFqdn -ErrorAction SilentlyContinue
    if (-not $existingDomainZone) {
        if ($CreateMissingZones) {
            Write-Log "Zone $domainFqdn absente -> création en AD-integrated / Domain replication / Secure updates"
            Add-DnsServerPrimaryZone -Name $domainFqdn -ReplicationScope Domain -DynamicUpdate Secure -PassThru | Out-Null
        } else {
            throw "La zone $domainFqdn est absente."
        }
    } else {
        Write-Log "Zone $domainFqdn présente."
        Set-DnsServerPrimaryZone -Name $domainFqdn -DynamicUpdate Secure -ReplicationScope Domain | Out-Null
        Write-Log "Zone $domainFqdn configurée en Secure dynamic update + réplication domaine."
    }

    $existingMsdcsZone = Get-DnsServerZone -Name $msdcsZone -ErrorAction SilentlyContinue
    if (-not $existingMsdcsZone) {
        if ($CreateMissingZones) {
            Write-Log "Zone $msdcsZone absente -> création en AD-integrated / Forest replication / Secure updates"
            Add-DnsServerPrimaryZone -Name $msdcsZone -ReplicationScope Forest -DynamicUpdate Secure -PassThru | Out-Null
        } else {
            throw "La zone $msdcsZone est absente."
        }
    } else {
        Write-Log "Zone $msdcsZone présente."
        Set-DnsServerPrimaryZone -Name $msdcsZone -DynamicUpdate Secure -ReplicationScope Forest | Out-Null
        Write-Log "Zone $msdcsZone configurée en Secure dynamic update + réplication forêt."
    }

    # 2) Vérifier que la carte réseau enregistre bien dans DNS
    $adapters = Get-DnsClient | Where-Object { $_.InterfaceOperationalStatus -eq "Up" -and $_.RegisterThisConnectionsAddress }
    if (-not $adapters) {
        Write-Log "Aucune interface active avec enregistrement DNS activé. Tentative d'activation."
        Get-DnsClient | Where-Object { $_.InterfaceOperationalStatus -eq "Up" } | ForEach-Object {
            try {
                Set-DnsClient -InterfaceIndex $_.InterfaceIndex -RegisterThisConnectionsAddress $true -UseSuffixWhenRegistering $true
                Write-Log "Interface $($_.InterfaceAlias) : enregistrement DNS activé."
            } catch {
                Write-Log "Impossible de modifier l'interface $($_.InterfaceAlias) : $($_.Exception.Message)"
            }
        }
    } else {
        foreach ($a in $adapters) {
            Write-Log "Interface OK pour DNS dynamic registration : $($a.InterfaceAlias)"
        }
    }

    # 3) Forcer réenregistrement DNS local
    Write-Log "Vidage cache DNS client"
    & ipconfig /flushdns | Out-Null

    Write-Log "Réenregistrement DNS client"
    & ipconfig /registerdns | Out-Null

    # 4) Redémarrer Netlogon et forcer DS registration
    Write-Log "Redémarrage du service Netlogon"
    Restart-Service -Name Netlogon -Force -ErrorAction Stop

    Start-Sleep -Seconds 10

    Write-Log "Forçage de l'enregistrement des records AD via nltest /dsregdns"
    & nltest /dsregdns | Out-Null

    Start-Sleep -Seconds 20

    # 5) Forcer la réplication AD
    Write-Log "Réplication AD : repadmin /syncall /AdeP"
    & repadmin /syncall /AdeP | Out-Null

    Start-Sleep -Seconds 10

    # 6) Contrôles basiques des zones
    $checks = @(
        "_ldap._tcp.dc._msdcs.$domainFqdn",
        "_kerberos._tcp.dc._msdcs.$domainFqdn",
        "_ldap._tcp.$domainFqdn",
        "_kerberos._tcp.$domainFqdn"
    )

    foreach ($name in $checks) {
        try {
            $result = Resolve-DnsName -Name $name -Type SRV -ErrorAction Stop
            if ($result) {
                Write-Log "OK SRV trouvé : $name"
            }
        } catch {
            Write-Log "ATTENTION : SRV introuvable pour $name"
        }
    }

    # 7) DCDIAG DNS
    Write-Log "Exécution de dcdiag /test:DNS /v"
    $dcdiagOut = & dcdiag /test:DNS /v
    $dcdiagFile = $LogPath -replace '\.log$', '.dcdiag.txt'
    $dcdiagOut | Out-File -FilePath $dcdiagFile -Encoding utf8
    Write-Log "Rapport DCDIAG écrit dans $dcdiagFile"

    Write-Log "Terminé."
    Write-Host ""
    Write-Host "Réparation terminée. Vérifie ensuite :"
    Write-Host " - le journal Système (Netlogon 5774/5781)"
    Write-Host " - le rapport DCDIAG"
    Write-Host " - la présence des dossiers _msdcs, _sites, _tcp, _udp dans DNS"
}
catch {
    Write-Error $_.Exception.Message
}
finally {
    Stop-Transcript | Out-Null
}