// Copyright (c) Cratis. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

namespace CratisAspire.SomeModule.SomeFeature.Registration;

[Command]
public record Register(SomeName Name)
{
    public (SomeId, Registered) Handle()
    {
        var eventSourceId = SomeId.New();

        return (eventSourceId, new(Name));
    }
}

[EventType]
public record Registered(SomeName Name);

public partial class RegistrationReactor(ILogger<RegistrationReactor> logger) : IReactor
{
    public Task Handle(Registered evt)
    {
        LogRegistered(evt.Name);
        return Task.CompletedTask;
    }

    [LoggerMessage(LogLevel.Information, "Registered: {Name}")]
    partial void LogRegistered(string name);
}
