using FluentMigrator;

namespace ClassLibrary.DatabaseMigrations
{
    [Migration(2)]
    public class AddUser02 : Migration
    {
        public override void Up()
        {
            Insert.IntoTable("Users")
                .InSchema("dbo")
                .Row(
                    new
                    {
                        Email = "02@email.com",
                        Password = "02_password"
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
                        Email = "02@email.com"
                    }
                );
        }
    }
}