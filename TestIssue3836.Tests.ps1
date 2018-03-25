$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "TestIssue3836" {
    Context "Something good required here" {
        It "does something useful" {
            $true | Should Be $false
        }
    }
}
