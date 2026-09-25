using CratisApp.SomeModule.SomeFeature.Registration;

namespace CratisApp.SomeModule.SomeFeature.Listing;

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
    public static ISubject<IEnumerable<Listing>> AllListings(CratisAppDbContext dbContext) =>
        dbContext.Listings.Observe();
#endif
}
