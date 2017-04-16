using FluentMigrator;

namespace ClassLibrary.DatabaseMigrations
{
    [Migration(3)]
    public class AddUser03 : Migration
    {
        public override void Up()
        {
            Insert.IntoTable("Users")
                .InSchema("dbo")
                .Row(
                    new
                    {
                        Email = "03@email.com",
                        Password = "03_password"
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
                        Email = "03@email.com"
                    }
                );
        }
    }
}