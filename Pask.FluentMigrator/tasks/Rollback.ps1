Import-Properties -Package Pask.FluentMigrator
Set-Property RollbackSteps -Default ""
Set-Property RollbackToVersion -Default ""

# Synopsis: Rollback database migrations using FluentMigrator
Task Rollback {
    Import-Script Properties.MigrationAssembly -Package Pask.FluentMigrator

    Assert (Test-Path $MigrationAssemblyFullName) "Cannot find the assembly $MigrationAssemblyFullName"

    $FluentMigratorConnectionString = property MigrationConnectionString

    $FluentMigratorTask = "--task=rollback"

    if ($RollbackSteps -and $RollbackSteps -ge 0) {
        "Rolling back $RollbackSteps steps"
        $FluentMigratorSteps = "--steps=$RollbackSteps"
    } elseif ($RollbackToVersion -and $RollbackToVersion -ge 0) {
        "Rolling back to version $RollbackToVersion"
        $FluentMigratorTask = "--task=rollback:toversion"
        $FluentMigratorVersion = "--version=""$RollbackToVersion"""
    } else {
        "Rolling back 1 step"
    }

    $FluentMigratorRunner = (Join-Path (Get-PackageDir "FluentMigrator") "tools\Migrate.exe")

    $MigrationTag -split ',' | ForEach { $FluentMigratorTag += @("--tag=""$_""") }

    Exec { & "$FluentMigratorRunner" --timeout="$MigrationTimeout" $FluentMigratorTask $FluentMigratorSteps $FluentMigratorVersion --connectionString="$FluentMigratorConnectionString" --db="$MigrationDatabase" --namespace="$MigrationNamespace" --target="$MigrationAssemblyFullName" --profile="$MigrationProfile" $FluentMigratorTag }
}