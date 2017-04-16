$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Script Pask.Tests.Infrastructure

Describe "Rollback" {
    BeforeAll {
        # Arrange
        $TestSolutionFullPath = Join-Path $Here "MigrateRollback"
        Install-NuGetPackage -Name Pask.FluentMigrator
        Add-Type -Path (Join-Path (Get-PackageDir "System.Data.SQLite.Core") "lib\net46\System.Data.SQLite.dll")
    }

    Context "Rollback without connection string" {
        It "should error" {
            { Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Rollback -ProjectName ClassLibrary.DatabaseMigrations } | Should Throw
        }
    }

    Context "Default rollback" {
        BeforeAll {
            # Arrange
            $Connection = New-Object -TypeName System.Data.SQLite.SQLiteConnection
            $Uri = New-Object -TypeName System.Uri (Join-Path $TestDrive "database.db")
            $Connection.ConnectionString = "Data Source={0}; Version=3; Mode=Memory; Cache=Shared; New=True" -f $Uri.LocalPath
            $Connection.Open()
            $Command = $Connection.CreateCommand()
            $Adapter = New-Object -TypeName System.Data.SQLite.SQLiteDataAdapter $Command

            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Migrate -ProjectName ClassLibrary.DatabaseMigrations -MigrationDatabase "SQLite" -MigrationConnectionString $Connection.ConnectionString
            Invoke-Pask $TestSolutionFullPath -Task Rollback -ProjectName ClassLibrary.DatabaseMigrations -MigrationDatabase "SQLite" -MigrationConnectionString $Connection.ConnectionString
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

    Context "Default rollback with profiles" {
        BeforeAll {
            # Arrange
            $Connection = New-Object -TypeName System.Data.SQLite.SQLiteConnection
            $Uri = New-Object -TypeName System.Uri (Join-Path $TestDrive "database.db")
            $Connection.ConnectionString = "Data Source={0}; Version=3; Mode=Memory; Cache=Shared; New=True" -f $Uri.LocalPath
            $Connection.Open()
            $Command = $Connection.CreateCommand()
            $Adapter = New-Object -TypeName System.Data.SQLite.SQLiteDataAdapter $Command

            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Migrate -ProjectName ClassLibrary.DatabaseMigrations -MigrationDatabase "SQLite" -MigrationConnectionString $Connection.ConnectionString -MigrationProfile "Development"
            Invoke-Pask $TestSolutionFullPath -Task Rollback -ProjectName ClassLibrary.DatabaseMigrations -MigrationDatabase "SQLite" -MigrationConnectionString $Connection.ConnectionString
        }

        It "rollback 1 step keeping the profile" {
            $Command.CommandText = "SELECT * FROM Users"
            $Data = New-Object System.Data.DataSet
            [void]$Adapter.Fill($Data)
            $Data.Tables[0].Rows.Count | Should Be 3
            $Data.Tables[0].Rows[0].Email | Should Be "01@email.com"
            $Data.Tables[0].Rows[1].Email | Should Be "02@email.com"
            $Data.Tables[0].Rows[2].Email | Should Be "dev@email.com"
        }

        AfterAll {
            # Teardown
            $Command.Dispose()
            $Adapter.Dispose()
            $Connection.Dispose()
        }
     }

    Context "Rollback steps" {
        BeforeAll {
            # Arrange
            $Connection = New-Object -TypeName System.Data.SQLite.SQLiteConnection
            $Uri = New-Object -TypeName System.Uri (Join-Path $TestDrive "database.db")
            $Connection.ConnectionString = "Data Source={0}; Version=3; Mode=Memory; Cache=Shared; New=True" -f $Uri.LocalPath
            $Connection.Open()
            $Command = $Connection.CreateCommand()
            $Adapter = New-Object -TypeName System.Data.SQLite.SQLiteDataAdapter $Command

            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Migrate -ProjectName ClassLibrary.DatabaseMigrations -MigrationDatabase "SQLite" -MigrationConnectionString $Connection.ConnectionString
            Invoke-Pask $TestSolutionFullPath -Task Rollback -ProjectName ClassLibrary.DatabaseMigrations -MigrationDatabase "SQLite" -MigrationConnectionString $Connection.ConnectionString -RollbackSteps 2
        }

        It "rollback the given number of steps" {
            $Command.CommandText = "SELECT * FROM Users"
            $Data = New-Object System.Data.DataSet
            [void]$Adapter.Fill($Data)
            $Data.Tables[0].Rows.Count | Should Be 1
            $Data.Tables[0].Rows[0].Email | Should Be "01@email.com"
        }

        AfterAll {
            # Teardown
            $Command.Dispose()
            $Adapter.Dispose()
            $Connection.Dispose()
        }
    }

    Context "Rollback to version" {
        BeforeAll {
            # Arrange
            $Connection = New-Object -TypeName System.Data.SQLite.SQLiteConnection
            $Uri = New-Object -TypeName System.Uri (Join-Path $TestDrive "database.db")
            $Connection.ConnectionString = "Data Source={0}; Version=3; Mode=Memory; Cache=Shared; New=True" -f $Uri.LocalPath
            $Connection.Open()
            $Command = $Connection.CreateCommand()
            $Adapter = New-Object -TypeName System.Data.SQLite.SQLiteDataAdapter $Command

            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Migrate -ProjectName ClassLibrary.DatabaseMigrations -MigrationDatabase "SQLite" -MigrationConnectionString $Connection.ConnectionString
            Invoke-Pask $TestSolutionFullPath -Task Rollback -ProjectName ClassLibrary.DatabaseMigrations -MigrationDatabase "SQLite" -MigrationConnectionString $Connection.ConnectionString -RollbackToVersion 1
        }

        It "rollback to the given version" {
            $Command.CommandText = "SELECT * FROM Users"
            $Data = New-Object System.Data.DataSet
            [void]$Adapter.Fill($Data)
            $Data.Tables[0].Rows.Count | Should Be 1
            $Data.Tables[0].Rows[0].Email | Should Be "01@email.com"
        }

        AfterAll {
            # Teardown
            $Command.Dispose()
            $Adapter.Dispose()
            $Connection.Dispose()
        }
    }
}