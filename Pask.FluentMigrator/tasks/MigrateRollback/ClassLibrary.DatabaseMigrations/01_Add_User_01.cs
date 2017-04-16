using FluentMigrator;

namespace ClassLibrary.DatabaseMigrations
{
    [Migration(1)]
    public class AddUser01 : Migration
    {
        public override void Up()
        {
            Insert.IntoTable("Users")
                .InSchema("dbo")
                .Row(
                    new
                    {
                        Email = "01@email.com",
                        Password = "01_password"
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
                        Email = "01@email.com"
                    }
                );
        }
    }
}