using FluentMigrator;

namespace ClassLibrary.DatabaseMigrations.Tags
{
    [Tags("UK")]
    [Migration(4)]
    public class AddUser04 : Migration
    {
        public override void Up()
        {
            Insert.IntoTable("Users")
                .InSchema("dbo")
                .Row(
                    new
                    {
                        Email = "04@email.com",
                        Password = "04_password"
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
                        Email = "04@email.com"
                    }
                );
        }
    }
}