Set-Property MigrationProjectName -Default { $ProjectName }
Set-Property MigrationAssemblyFullPath -Default { Get-ProjectBuildOutputDir $MigrationProjectName }
Set-Property MigrationAssemblyFullName -Default { if ($MigrationAssemblyFullPath) { Join-Path $MigrationAssemblyFullPath "$MigrationProjectName.dll" } }
Set-Property MigrationNamespace -Default ""
Set-Property MigrationConnectionString -Default "Server=.,1434;Database=MiCoreDb2;Trusted_Connection=true;MultipleActiveResultSets=True;"
Set-Property MigrationTimeout -Default 1200
Set-Property MigrationProfile -Default ""
Set-Property MigrationTag -Default ""
Set-Property MigrationDatabase -Default "SqlServer"

# Synopsis: Execute database migrations using FluentMigrator
Task Migrate {
    Assert (Test-Path $MigrationAssemblyFullName) "Cannot find the assembly $MigrationAssemblyFullName"

    $FluentMigratorRunner = (Join-Path (Get-PackageDir "FluentMigrator") "tools\Migrate.exe")

    $MigrationTag -split ',' | ForEach { $Tag += @("--tag=""$_""") }

    Exec { & "$FluentMigratorRunner" --timeout="$MigrationTimeout" --connectionString="$MigrationConnectionString" --db="$MigrationDatabase" --namespace="$MigrationNamespace" --target="$MigrationAssemblyFullName" --profile="$MigrationProfile" $Tag }
}