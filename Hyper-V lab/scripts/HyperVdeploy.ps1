configuration HyperVdeploy
{
Import-DscResource -ModuleName 'PSDesiredStateConfiguration', 'xHyper-V', 'xPSDesiredStateConfiguration'

    Node HyperV001
    {
        WindowsFeature Hyper-V
        {
            Ensure               = 'Present'
            Name                 = 'Hyper-V'
            IncludeAllSubFeature = $true
        }

        WindowsFeature Failover-Clustering
        {
            Ensure = 'Present'
            Name = 'Failover-Clustering'
        }

        WindowsFeature Hyper-V-PowerShell
        {
            Ensure = 'Present'
            Name='Hyper-V-PowerShell'
            IncludeAllSubFeature = $true
        }

        WindowsFeature Hyper-V-Tools
        {
            Ensure = 'Present'
            Name='Hyper-V-Tools'
        }
        
        xVMSwitch InternalVSwitch 
        {
        DependsOn = '[WindowsFeature]Hyper-V'
        Name = 'IntvSwitch'
        Ensure = 'Present'
        Type = 'Internal'
        }
 
        $NewSystemVHDPath = "C:\\VM\OS\sourceVM2k16.vhdx"
        
        File SetupDir {
        Type            = 'Directory'
        DestinationPath = 'c:\\VM\OS'
        Ensure          = "Present"    
        }
       
        xRemoteFile vhdxinstall {  
        Uri             = "long uri to vhdx"
        DestinationPath =  $NewSystemVHDPath
        DependsOn       =  "[File]SetupDir"
        MatchSource     =  $false
    
        }

        xVMHyperV NewVM
        {
            Ensure          = 'Present'
            Name            = 'HyperV001vm'
            VhdPath         = $NewSystemVHDPath
            SwitchName      = 'IntvSwitch'
            State           = 'Running'
            Path            = 'C:\\VM\OS'
            Generation      = '1'
            MinimumMemory   = 2GB
            MaximumMemory   = 4GB
            ProcessorCount  = '1'
            RestartIfNeeded = $true
            DependsOn       = "[xRemoteFile]vhdxinstall"
        }
    }
   
}     
   
