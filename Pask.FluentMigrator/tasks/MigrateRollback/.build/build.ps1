Import-Task Restore-NuGetPackages, Clean, Build, Migrate, Rollback, New-Artifact, Zip-Artifact, Extract-Artifact, `
            MigrateFrom-Artifact, RollbackFrom-Artifact, MigrateFrom-Package, RollbackFrom-Package

# Synopsis: Default task
Task . Restore-NuGetPackages, Clean, Build

# Synopsis: Migrate from custom project
Task MigrateFrom-ClassLibraryDatabaseMigrations {
    Set-Project -Name ClassLibrary.DatabaseMigrations
}, Migrate