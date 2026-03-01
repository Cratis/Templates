using CratisApp.Features.SomeFeature.Registration;
using MongoDB.Driver;

namespace CratisApp.Features.SomeFeature.Listing;

[ReadModel]
public record Listing(SomeName Name, EventSourceId EventSourceId)
{
    public static ISubject<IEnumerable<Listing>> AllListings(IMongoCollection<Listing> collection) =>
        collection.Observe();
}

public class ListingProjection : IProjectionFor<Listing>
{
    public void Define(IProjectionBuilderFor<Listing> builder) => builder
        .AutoMap()
        .From<Registered>();
}
