﻿$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Script Pask.Tests.Infrastructure

Describe "RollbackFrom-Artifact" {
    BeforeAll {
        # Arrange
        $TestSolutionFullPath = Join-Path $Here "MigrateRollback"
        Install-NuGetPackage -Name Pask.FluentMigrator
        Add-Type -Path (Join-Path (Get-PackageDir "System.Data.SQLite.Core") "lib\net46\System.Data.SQLite.dll")
    }

    Context "Default rollback from new artifact" {
        BeforeAll {
            # Arrange
            $Connection = New-Object -TypeName System.Data.SQLite.SQLiteConnection
            $Uri = New-Object -TypeName System.Uri (Join-Path $TestDrive "database.db")
            $Connection.ConnectionString = "Data Source={0}; Version=3; Mode=Memory; Cache=Shared; New=True" -f $Uri.LocalPath
            $Connection.Open()
            $Command = $Connection.CreateCommand()
            $Adapter = New-Object -TypeName System.Data.SQLite.SQLiteDataAdapter $Command

            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Migrate, New-Artifact -ProjectName ClassLibrary.DatabaseMigrations -MigrationDatabase "SQLite" -MigrationConnectionString $Connection.ConnectionString
            Remove-PaskItem (Join-Path $TestSolutionFullPath "ClassLibrary\bin")
            Remove-PaskItem (Join-Path $TestSolutionFullPath "ClassLibrary\obj")
            Remove-PaskItem (Join-Path $TestSolutionFullPath "ClassLibrary.DatabaseMigrations\obj")
            Remove-PaskItem (Join-Path $TestSolutionFullPath "ClassLibrary.DatabaseMigrations\obj")
            Invoke-Pask $TestSolutionFullPath -Task RollbackFrom-Artifact -ProjectName ClassLibrary.DatabaseMigrations -MigrationDatabase "SQLite" -MigrationConnectionString $Connection.ConnectionString
        }

        It "rollback 1 step" {
            $Command.CommandText = "SELECT * FROM Users"
            $Data = New-Object System.Data.DataSet
            [void]$Adapter.Fill($Data)
            $Data.Tables[0].Rows.Count | Should Be 2
            $Data.Tables[0].Rows[0].Email | Should Be "01@email.com"
            $Data.Tables[0].Rows[1].Email | Should Be "02@email.com"
        }

        AfterAll {
            # Teardown
            $Command.Dispose()
            $Adapter.Dispose()
            $Connection.Dispose()
        }
    }
}