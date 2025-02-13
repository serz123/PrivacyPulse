using Microsoft.EntityFrameworkCore;

namespace Authentication.src.data
{
    public class SlaveDbContext : DbContext
    {
        public DbSet<User> Users { get; set; }
        public DbSet<ScrapedData> ScrapedDatas { get; set; }  // Add DbSet for ScrapedData

        public SlaveDbContext(DbContextOptions<SlaveDbContext> options) : base(options) { }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // Configure the relationship between ScrapedData and User using Email as the foreign key
            modelBuilder.Entity<ScrapedData>()
                .HasOne(s => s.User)  // ScrapedData has one User
                .WithMany(u => u.ScrapedDatas)  // User can have many ScrapedData
                .HasForeignKey(s => s.Email)  // Set Email as the foreign key
                .HasPrincipalKey(u => u.Email);  // Set Email as the primary key in User table

            // Ensure that Email is unique in the User table
            modelBuilder.Entity<User>()
                .HasIndex(u => u.Email)
                .IsUnique();  // Make sure the Email is unique
        }
    }
}
