using FluentMigrator;

namespace ClassLibrary.DatabaseMigrations.Tags
{
    [Tags("Production")]
    [Migration(6)]
    public class AddUser06 : Migration
    {
        public override void Up()
        {
            Insert.IntoTable("Users")
                .InSchema("dbo")
                .Row(
                    new
                    {
                        Email = "06@email.com",
                        Password = "06_password"
                    }
                );
        }

        public override void Down()
        {
            Delete.FromTable("Users")
                .InSchema("dbo")
                .Row(
                    new
                    {
                        Email = "06@email.com"
                    }
                );
        }
    }
}