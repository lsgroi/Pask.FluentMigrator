Import-Task Migrate

# Synopsis: Execute database migrations using FluentMigrator from an artifact
Task MigrateFrom-Artifact {
    Set-Property MigrationAssemblyFullPath -Value (Join-Path $BuildOutputFullPath $MigrationProjectName) -Update
}, Migrate