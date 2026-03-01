
namespace CratisApp.Features.SomeFeature.Registration;

[Command]
public record Register(SomeName Name)
{
    public (Guid, Registered) Handle()
    {
        var eventSourceId = Guid.NewGuid();

        return (eventSourceId, new(Name));
    }
}

[EventType]
public record Registered(SomeName Name);

public partial class RegistrationReactor(ILogger<RegistrationReactor> logger) : IReactor
{
    // readonly ILogger<RegistrationReactor> _logger = logger;
    public Task Handle(Registered evt)
    {
        LogRegistered(evt.Name);
        return Task.CompletedTask;
    }

    [LoggerMessage(LogLevel.Information, "Registered: {Name}")]
    partial void LogRegistered(string name);
}
