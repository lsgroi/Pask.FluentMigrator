$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Script Pask.Tests.Infrastructure

Describe "Migrate" {
    BeforeAll {
        # Arrange
        $TestSolutionFullPath = Join-Path $Here "MigrateRollback"
        Install-NuGetPackage -Name Pask.FluentMigrator
        Add-Type -Path (Join-Path (Get-PackageDir "System.Data.SQLite.Core") "lib\net46\System.Data.SQLite.dll")
    }

    Context "Migrate without connection string" {
        It "should error" {
            { Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Migrate -ProjectName ClassLibrary.DatabaseMigrations } | Should Throw
        }
    }

    Context "Migration from default project" {
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
        }

        It "applies the migration" {
            $Command.CommandText = "SELECT * FROM Users"
            $Data = New-Object System.Data.DataSet
            [void]$Adapter.Fill($Data)
            $Data.Tables[0].Rows.Count | Should Be 3
            $Data.Tables[0].Rows[0].Email | Should Be "01@email.com"
            $Data.Tables[0].Rows[1].Email | Should Be "02@email.com"
            $Data.Tables[0].Rows[2].Email | Should Be "03@email.com"
        }

        AfterAll {
            # Teardown
            $Command.Dispose()
            $Adapter.Dispose()
            $Connection.Dispose()
        }
    }

    Context "Migration from custom project" {
        BeforeAll {
            # Arrange
            $Connection = New-Object -TypeName System.Data.SQLite.SQLiteConnection
            $Uri = New-Object -TypeName System.Uri (Join-Path $TestDrive "database.db")
            $Connection.ConnectionString = "Data Source={0}; Version=3; Mode=Memory; Cache=Shared; New=True" -f $Uri.LocalPath
            $Connection.Open()
            $Command = $Connection.CreateCommand()
            $Adapter = New-Object -TypeName System.Data.SQLite.SQLiteDataAdapter $Command

            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, MigrateFrom-ClassLibraryDatabaseMigrations -MigrationDatabase "SQLite" -MigrationConnectionString $Connection.ConnectionString
        }

        It "applies the migration" {
            $Command.CommandText = "SELECT * FROM Users"
            $Data = New-Object System.Data.DataSet
            [void]$Adapter.Fill($Data)
            $Data.Tables[0].Rows.Count | Should Be 3
            $Data.Tables[0].Rows[0].Email | Should Be "01@email.com"
            $Data.Tables[0].Rows[1].Email | Should Be "02@email.com"
            $Data.Tables[0].Rows[2].Email | Should Be "03@email.com"
        }

        AfterAll {
            # Teardown
            $Command.Dispose()
            $Adapter.Dispose()
            $Connection.Dispose()
        }
    }

    Context "Migration of single tag" {
        BeforeAll {
            # Arrange
            $Connection = New-Object -TypeName System.Data.SQLite.SQLiteConnection
            $Uri = New-Object -TypeName System.Uri (Join-Path $TestDrive "database.db")
            $Connection.ConnectionString = "Data Source={0}; Version=3; Mode=Memory; Cache=Shared; New=True" -f $Uri.LocalPath
            $Connection.Open()
            $Command = $Connection.CreateCommand()
            $Adapter = New-Object -TypeName System.Data.SQLite.SQLiteDataAdapter $Command

            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Migrate -ProjectName ClassLibrary.DatabaseMigrations -MigrationDatabase "SQLite" -MigrationConnectionString $Connection.ConnectionString -MigrationTag "UK"
        }

        It "applies the migration" {
            $Command.CommandText = "SELECT * FROM Users"
            $Data = New-Object System.Data.DataSet
            [void]$Adapter.Fill($Data)
            $Data.Tables[0].Rows.Count | Should Be 5
            $Data.Tables[0].Rows[0].Email | Should Be "01@email.com"
            $Data.Tables[0].Rows[1].Email | Should Be "02@email.com"
            $Data.Tables[0].Rows[2].Email | Should Be "03@email.com"
            $Data.Tables[0].Rows[3].Email | Should Be "04@email.com"
            $Data.Tables[0].Rows[4].Email | Should Be "05@email.com"
        }

        AfterAll {
            # Teardown
            $Command.Dispose()
            $Adapter.Dispose()
            $Connection.Dispose()
        }
    }

    Context "Migration of multiple tags" {
        BeforeAll {
            # Arrange
            $Connection = New-Object -TypeName System.Data.SQLite.SQLiteConnection
            $Uri = New-Object -TypeName System.Uri (Join-Path $TestDrive "database.db")
            $Connection.ConnectionString = "Data Source={0}; Version=3; Mode=Memory; Cache=Shared; New=True" -f $Uri.LocalPath
            $Connection.Open()
            $Command = $Connection.CreateCommand()
            $Adapter = New-Object -TypeName System.Data.SQLite.SQLiteDataAdapter $Command

            # Act
            Invoke-Pask $TestSolutionFullPath -Task Restore-NuGetPackages, Clean, Build, Migrate -ProjectName ClassLibrary.DatabaseMigrations -MigrationDatabase "SQLite" -MigrationConnectionString $Connection.ConnectionString -MigrationTag "UK,Production"
        }

        It "applies the migration" {
            $Command.CommandText = "SELECT * FROM Users"
            $Data = New-Object System.Data.DataSet
            [void]$Adapter.Fill($Data)
            $Data.Tables[0].Rows.Count | Should Be 4
            $Data.Tables[0].Rows[0].Email | Should Be "01@email.com"
            $Data.Tables[0].Rows[1].Email | Should Be "02@email.com"
            $Data.Tables[0].Rows[2].Email | Should Be "03@email.com"
            $Data.Tables[0].Rows[3].Email | Should Be "05@email.com"
        }

        AfterAll {
            # Teardown
            $Command.Dispose()
            $Adapter.Dispose()
            $Connection.Dispose()
        }
    }

    Context "Migration with profile" {
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
        }

        It "applies the migration and the profile" {
            $Command.CommandText = "SELECT * FROM Users"
            $Data = New-Object System.Data.DataSet
            [void]$Adapter.Fill($Data)
            $Data.Tables[0].Rows.Count | Should Be 4
            $Data.Tables[0].Rows[0].Email | Should Be "01@email.com"
            $Data.Tables[0].Rows[1].Email | Should Be "02@email.com"
            $Data.Tables[0].Rows[2].Email | Should Be "03@email.com"
            $Data.Tables[0].Rows[3].Email | Should Be "dev@email.com"
        }

        AfterAll {
            # Teardown
            $Command.Dispose()
            $Adapter.Dispose()
            $Connection.Dispose()
        }
     }
}