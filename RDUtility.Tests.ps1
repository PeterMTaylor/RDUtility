#---------------------------------# 
# PSScriptAnalyzer tests          # 
#---------------------------------# 
$Scripts = Get-ChildItem "$PSScriptRoot\..\" -Filter '*.ps1' -Recurse | Where-Object {$_.name -NotMatch 'Tests.ps1'}
$Modules = Get-ChildItem "$PSScriptRoot\..\" -Filter '*.psm1' -Recurse
$Rules   = Get-ScriptAnalyzerRule

if ($Modules.count -gt 0) {
  Describe 'Testing all Modules against default PSScriptAnalyzer rule-set' {
    foreach ($module in $modules) {
      Context "Testing Module '$($module.FullName)'" {
        foreach ($rule in $rules) {
          It "passes the PSScriptAnalyzer Rule $rule" {
            (Invoke-ScriptAnalyzer -Path $module.FullName -IncludeRule $rule.RuleName ).Count | Should Be 0
          }
        }
      }
    }
  }
}
if ($Scripts.count -gt 0) {
  Describe 'Testing all Script against default PSScriptAnalyzer rule-set' {
    foreach ($Script in $scripts) {
      Context "Testing Script '$($script.FullName)'" {
        foreach ($rule in $rules) {
          It "passes the PSScriptAnalyzer Rule $rule" {
            if (-not ($module.BaseName -match 'AppVeyor') -and -not ($rule.Rulename -eq 'PSAvoidUsingWriteHost') ) {
              (Invoke-ScriptAnalyzer -Path $script.FullName -IncludeRule $rule.RuleName ).Count | Should Be 0
            }
          }
        }
      }
    }
  }
}

#-------------------------# 
# CodeAudit Pester tests  # 
#-------------------------# 

$moduleName = 'RDUtility';
if (!$PSScriptRoot) { # $PSScriptRoot is not defined in 2.0
    $PSScriptRoot = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Path)
}
$repoRoot = (Resolve-Path $PSScriptRoot).Path;

Import-Module (Join-Path -Path $RepoRoot -ChildPath "$moduleName.psm1") -Force;

Describe $moduleName {   
    $FunctionsList = (get-command -Module $moduleName | Where-Object -FilterScript { $_.CommandType -eq 'Function' }).Name
    
    FOREACH ($Function in $FunctionsList)
    {
        # Retrieve the Help of the function
        $Help = Get-Help -Name $Function -Full
        
        $Notes = ($Help.alertSet.alert.text -split '\n')
        # Parse the function using AST
        $AST = [System.Management.Automation.Language.Parser]::ParseInput((Get-Content function:$Function), [ref]$null, [ref]$null)    
        
        Context "$Function - Help" {
            
            It "Synopsis" { $help.Synopsis | Should not BeNullOrEmpty }
            It "Description" { $help.Description | Should not BeNullOrEmpty }
            It "Notes - Author" { $Notes[0].trim() | Should Be "Peter M Taylor for github.com/" }
            It "Notes - Site" { $Notes[1].trim() | Should Be "https://petermtaylor.github.io/" }
            It "Notes - Github" { $Notes[3].trim() | Should Be "github.com/PeterMTaylor" }
            It "Notes - Twitter" { $Notes[2].trim() | Should Be "@peterlearning24" }
            
            # Get the parameters declared in the Comment Based Help
            $RiskMitigationParameters = 'Whatif', 'Confirm'
            $HelpParameters = $help.parameters.parameter | Where-Object name -NotIn $RiskMitigationParameters
            
            # Get the parameters declared in the AST PARAM() Block
            $ASTParameters = $ast.ParamBlock.Parameters.Name.variablepath.userpath
            
            $FunctionsList = (get-command -Module $ModuleName | Where-Object -FilterScript { $_.CommandType -eq 'Function' }).Name 
            
            It "Parameter - Compare Count Help/AST" {
                $HelpParameters.name.count -eq $ASTParameters.count | Should Be $true
            } # end parameter
            
            # Parameter Description
            If (-not [String]::IsNullOrEmpty($ASTParameters)) # IF ASTParameters are found
            {
                $HelpParameters | ForEach-Object {
                    It "Parameter $($_.Name) - Should contains description" {
                        $_.description | Should not BeNullOrEmpty
                    } # end foreach-object
                }  # End helpParameters
                
            } # end IsNullOrEmpty $ASTParameters
            
            # Examples
            it "Example - Count should be greater than 0" {
                $Help.examples.example.code.count | Should BeGreaterthan 0
            }
            
            # Examples - Remarks (small description that comes with the example)
            foreach ($Example in $Help.examples.example) {
                it "Example - Remarks on $($Example.Title)" {
                    $Example.remarks | Should not BeNullOrEmpty
                } # End Example Remarks
            } # End foreach
          } # end context function help
        } # end for each function
  
  #Need code to read the script to check 
    It 'Display purpose and information' -Pending {
       RDutility | Should Be 'Hello World!'
    }
    #Show that what happens here in appveyor works on PC
    It 'Prove that this change works on the desktop as I do here testing in Appveyor' -Pending
    { 
        RDUtility | Should Be 'Hello World!'
    }
    
    #Learn more about local data and accessing them during test 
    It 'Obtain the Github release location via localpassed variable' -Pending
    { 
        RDUtility | Should Be 'Hello World!'
    }
    
    #Learn how Testdrive works
    It 'Able to determine if I am x86 or 64 bit' -Pending
    { 
        RDUtility | Should Be 'Hello World!'
    }
     
    Context "RDUtility" {
    It "RDUtility displays HelloWorld" {
        RDUtility | Should Be 'Hello World!'

        }
    }  
} #End Describe
