
namespace CratisApp.Features.SomeFeature.Registration;

[Command]
public record Register(SomeName Name)
{
    public Registered Handle() => new(Name);
}

[EventType]
public record Registered(SomeName Name);

