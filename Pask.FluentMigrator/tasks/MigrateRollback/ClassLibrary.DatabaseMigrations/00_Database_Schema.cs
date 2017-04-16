using FluentMigrator;

namespace ClassLibrary.DatabaseMigrations
{
    [Migration(0)]
    public class Database_Schema : ForwardOnlyMigration
    {
        public override void Up()
        {
            Create.Schema("dbo");

            Create.Table("Users").InSchema("dbo")
                .WithColumn("Id").AsInt32().NotNullable().Identity().PrimaryKey()
                .WithColumn("Email").AsString().NotNullable()
                .WithColumn("Password").AsString().NotNullable();
        }
    }
}
