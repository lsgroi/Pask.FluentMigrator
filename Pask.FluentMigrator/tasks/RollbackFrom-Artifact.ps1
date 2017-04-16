Import-Task Rollback

# Synopsis: Rollback database migrations using FluentMigrator from an artifact
Task RollbackFrom-Artifact {
    Set-Property MigrationAssemblyFullPath -Value (Join-Path $BuildOutputFullPath $MigrationProjectName) -Refresh
}, Rollback