using AnApp.Features.SomeFeature.Registration;

namespace AnApp.Features.SomeFeature.Listing;

[ReadModel, FromEvent<Registered>]
public record Listing(string Name, [SetFromContext<Registered>]EventSourceId EventSourceId)
{
    public static Task<Listing> GetByEventSourceId(EventSourceId eventSourceId, IReadModels readModels)
        => readModels.GetInstanceById<Listing>(eventSourceId);

    // public static ISubject<Listing> ObserveAll(IReadModels readModels)
    //     => ClientObservable< readModels.Watch<Listing>();

    public static Task<IEnumerable<Listing>> GetAll(IReadModels readModels)
        => readModels.GetInstances<Listing>();
}