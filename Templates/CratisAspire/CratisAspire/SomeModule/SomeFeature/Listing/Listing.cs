using CratisAspire.SomeModule.SomeFeature.Registration;

namespace CratisAspire.SomeModule.SomeFeature.Listing;

[ReadModel]
[FromEvent<Registered>]
public record Listing(
    Guid Id,
    SomeName Name,
    [SetFromContext<Registered>(nameof(EventContext.EventSourceId))] EventSourceId EventSourceId)
{
#if cratisMongoDb
    public static ISubject<IEnumerable<Listing>> AllListings(IMongoCollection<Listing> collection) =>
        collection.Observe();
#else
    public static ISubject<IEnumerable<Listing>> AllListings(CratisAspireDbContext dbContext) =>
        dbContext.Listings.Observe();
#endif
}
