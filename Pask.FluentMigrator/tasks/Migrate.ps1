Import-Properties -Package Pask.FluentMigrator

# Synopsis: Execute database migrations using FluentMigrator
Task Migrate {
    Import-Script Properties.MigrationAssembly -Package Pask.FluentMigrator

    Assert (Test-Path $MigrationAssemblyFullName) "Cannot find the assembly $MigrationAssemblyFullName"

    $FluentMigratorConnectionString = property MigrationConnectionString

    $FluentMigratorRunner = (Join-Path (Get-PackageDir "FluentMigrator") "tools\Migrate.exe")

    $MigrationTag -split ',' | ForEach { $FluentMigratorTag += @("--tag=""$_""") }

    Exec { & "$FluentMigratorRunner" --timeout="$MigrationTimeout" --connectionString="$FluentMigratorConnectionString" --db="$MigrationDatabase" --namespace="$MigrationNamespace" --target="$MigrationAssemblyFullName" --profile="$MigrationProfile" $FluentMigratorTag }
}