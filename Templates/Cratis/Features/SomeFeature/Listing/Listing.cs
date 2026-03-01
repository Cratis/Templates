using CratisApp.Features.SomeFeature.Registration;

namespace CratisApp.Features.SomeFeature.Listing;

[ReadModel]
public record Listing(SomeName Name, EventSourceId EventSourceId)
{
    public static ISubject<IEnumerable<Listing>> AllListings(IReadModels readModels) =>
        readModels.Watch<Listing>();
}

public class ListingProjection : IProjectionFor<Listing>
{
    public void Define(IProjectionBuilderFor<Listing> builder) => builder
        .AutoMap()
        .From<Registered>();
}
