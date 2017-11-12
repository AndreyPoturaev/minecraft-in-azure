Configuration MinecraftServer
{

    param (
        [string] $minecraftVersion = "1.12.2",
        [string] $containerName = "server",
        [string] $accountName = "minedisk",
        [string] $vmName = ""
    )

    
    Import-DscResource -ModuleName @{ModuleName="xPSDesiredStateConfiguration"; ModuleVersion="7.0.0.0"}
    Import-DscResource -ModuleName @{ModuleName="xNetworking"; ModuleVersion="5.1.0.0"}
    Import-DscResource -ModuleName @{ModuleName="xStorage"; ModuleVersion="3.2.0.0"}

    $mineHomeRoot = "C:\minecraft"
    $mineHome = "$mineHomeRoot\mineserver"    
    
    Node $vmName
    {
        xRemoteFile DistrCopy
        {
            Uri = "https://$accountName.blob.core.windows.net/$containerName/mineserver.$minecraftVersion.zip"
            DestinationPath = "$mineHome.zip"
            MatchSource = $true
        }

        Archive UnzipServer 
        {
            Ensure = "Present"
            Path = "$mineHome.zip"
            Destination = $mineHomeRoot
            DependsOn = "[xRemoteFile]DistrCopy"
            Validate = $true
            Force = $true
        }

		File CheckProperties
		{
			DestinationPath = "$mineHome\server.properties"
			Type = "File"
			Ensure = "Present"
            Force = $true
			Contents = "
				generator-settings=
				op-permission-level=4
				allow-nether=true
				level-name=world
				enable-query=false
				allow-flight=true
				prevent-proxy-connections=false
				server-port=25565
				max-world-size=29999984
				level-type=DEFAULT
				enable-rcon=false
				force-gamemode=false
				level-seed=
				server-ip=
				network-compression-threshold=256
				max-build-height=256
				spawn-npcs=true
				white-list=false
				spawn-animals=true
				snooper-enabled=true
				hardcore=false
				resource-pack-sha1=
				online-mode=false
				resource-pack=
				pvp=false
				difficulty=1
				enable-command-block=true
				player-idle-timeout=0
				gamemode=1
				max-players=5
				max-tick-time=60000
				spawn-monsters=true
				generate-structures=true
				view-distance=50
				motd=Dima Minecraft Server"				
			DependsOn = "[Archive]UnzipServer"
		}

        File CheckEULA
		{
			DestinationPath = "$mineHome\eula.txt"
			Type = "File"
			Ensure = "Present"
            Force = $true
            Contents = "
            #By changing the setting below to TRUE you are indicating your agreement to our EULA (https://account.mojang.com/documents/minecraft_eula).
            #Tue Sep 26 08:50:13 UTC 2017
            eula=true"				
			DependsOn = "[File]CheckProperties"
		}
		
		File CheckLoggingSettings
		{
			DestinationPath = "$mineHome\log4j2.xml"
			Type = "File"
			Ensure = "Present"
            Force = $true
			DependsOn = "[File]CheckEULA"
			Contents = "<?xml version='1.0' encoding='UTF-8'?>
<Configuration status='WARN' packages='com.mojang.util'>
    <Appenders>
        <Console name='SysOut' target='SYSTEM_OUT'>
            <PatternLayout pattern='[%d{HH:mm:ss}] [%t/%level]: %msg%n' />
        </Console>
        <Queue name='ServerGuiConsole'>
            <PatternLayout pattern='[%d{HH:mm:ss} %level]: %msg%n' />
        </Queue>
        <RollingRandomAccessFile name='File' fileName=`"$mineHome\latest.log`" filePattern=`"$mineHome\logs\%d{yyyy-MM-dd}\%d{HH}\%d{HH-mm-ss}-%i.log.gz`">
            <PatternLayout pattern='%d{yyyy-MM-dd HH:mm:ss};%level;%msg%n'>
                <header>TS;LEVEL;MESSAGE%n</header>
            </PatternLayout>
            <Policies>
                <CronTriggeringPolicy schedule='0/30 * * * * ?' evaluateOnStartup='true'/>
                <SizeBasedTriggeringPolicy size='10 MB'/>
            </Policies>
            <DefaultRolloverStrategy max='100'/>
        </RollingRandomAccessFile>
    </Appenders>
    <Loggers>
        <Root level='info'>
            <filters>
                <MarkerFilter marker='NETWORK_PACKETS' onMatch='DENY' onMismatch='NEUTRAL' />
            </filters>
            <AppenderRef ref='SysOut'/>
            <AppenderRef ref='File'/>
            <AppenderRef ref='ServerGuiConsole'/>
        </Root>
    </Loggers>
</Configuration>"
		}

        xWaitForDisk WaitWorldDisk
        {
            DiskIdType = "Number"
            DiskId = "2"   
            RetryIntervalSec = 60	
            RetryCount = 5
            DependsOn = "[File]CheckLoggingSettings"
        }

        xDisk PrepareWorldDisk
        {
            DependsOn = "[xWaitForDisk]WaitWorldDisk"
            DiskIdType = "Number"
            DiskId = "2"
            DriveLetter = "F"
            AllowDestructive = $false
        }

        xWaitForVolume WaitForF
        {
            DriveLetter      = 'F'
            RetryIntervalSec = 5
            RetryCount       = 10
            DependsOn = "[xDisk]PrepareWorldDisk"
        }

        File WorldDirectoryExists
        {
            Ensure = "Present" 
            Type = "Directory"
            Recurse = $true
            DestinationPath = "F:\world"
            SourcePath = "$mineHome\initial_world"
            MatchSource = $false
            DependsOn = "[xWaitForVolume]WaitForF"    
        }

        Script LinkWorldDirectory
        {
            DependsOn="[File]WorldDirectoryExists"
            GetScript=
            {
                @{ Result =  (Test-Path "$using:mineHome\World") }
            }
            SetScript=
            {
                New-Item -ItemType SymbolicLink -Path "$using:mineHome\World" -Confirm -Force -Value "F:\world"                
            }
            TestScript=
            {
                return (Test-Path "$using:mineHome\World")
            }
        }

        Script EnsureServerStart
        {
            DependsOn="[Script]LinkWorldDirectory"
            GetScript=
            {
                @{ Result = (Get-Process -Name java -ErrorAction SilentlyContinue) } 
            }
            SetScript=
            {
                Start-Process -FilePath "$using:mineHome\jre\bin\java" -WorkingDirectory "$using:mineHome" -ArgumentList "-Xms512M -Xmx512M -Dlog4j.configurationFile=`"$using:mineHome\log4j2.xml`"  -jar `"$using:mineHome\minecraft_server.$using:minecraftVersion.jar`" nogui"                
            }
            TestScript=
            {
                return (Get-Process -Name java -ErrorAction SilentlyContinue) -ne $null
            }
        }
        
        xFirewall FirewallIn 
        { 
            Name = "Minecraft-in"             
            Action = "Allow" 
            LocalPort = ('25565')
            Protocol = 'TCP'
            Direction = 'Inbound'
        }

        xFirewall FirewallOut 
        { 
            Name = "Minecraft-out"             
            Action = "Allow" 
            LocalPort = ('25565')
            Protocol = 'TCP'
            Direction = 'Outbound'
        }
    }
}