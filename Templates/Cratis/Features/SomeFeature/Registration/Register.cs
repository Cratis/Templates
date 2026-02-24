
namespace AnApp.Features.SomeFeature.Registration;

[Command]
public record Register(string Name)
{
    public Registered Handle() => new(Name);
}

[EventType]
public record Registered(string Name);
