#if cratisEntityFrameworkCore
using CratisAspire.SomeModule.SomeFeature.Listing;

namespace CratisAspire;

/// <summary>
/// The read-only context the application reads its read models through.
/// </summary>
public class CratisAspireDbContext(DbContextOptions<CratisAspireDbContext> options) : ReadOnlyDbContext(options)
{
    /// <summary>
    /// Gets the listings read model set.
    /// </summary>
    public DbSet<Listing> Listings => Set<Listing>();

    /// <inheritdoc/>
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<Listing>().ToTable("Listings");
    }
}
#endif
