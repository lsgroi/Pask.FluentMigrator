using FluentMigrator;

namespace ClassLibrary.DatabaseMigrations.Tags
{
    [Tags("UK", "US")]
    [Tags("Production")]
    [Migration(5)]
    public class AddUser05 : Migration
    {
        public override void Up()
        {
            Insert.IntoTable("Users")
                .InSchema("dbo")
                .Row(
                    new
                    {
                        Email = "05@email.com",
                        Password = "05_password"
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
                        Email = "05@email.com"
                    }
                );
        }
    }
}