using FluentMigrator;

namespace ClassLibrary.DatabaseMigrations.Profiles
{
    [Profile("Development")]
    public class DevProfile : Migration
    {
        public override void Up()
        {
            Insert.IntoTable("Users")
                .InSchema("dbo")
                .Row(
                    new
                    {
                        Email = "dev@email.com",
                        Password = "dev_password"
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
                        Email = "dev@email.com"
                    }
                );
        }
    }
}