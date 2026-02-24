using Cratis.Chronicle.Events;
using Cratis.Chronicle.EventSequences;
using Cratis.Chronicle.Projections.ModelBound;
using Cratis.Chronicle.Reactors;
using Cratis.Chronicle.ReadModels;

var builder = WebApplication.CreateBuilder(args)
    .AddCratisChronicle();

var app = builder.Build();

app.UseCratisChronicle();

app.MapGet("/", (IEventLog log) => log.Append(Guid.NewGuid().ToString(), new TestEvent("Hello, Chronicle!")));
app.MapGet("/projection", (IReadModels readModels) => readModels.GetInstances<TestProjection>());

await app.RunAsync();

[FromEvent<TestEvent>]
public record TestProjection(
    string Message,
    [SetFromContext<TestEvent>(nameof(EventContext.EventSourceId))] string EventSource);

public class TestReactor : IReactor
{
    public Task React(TestEvent @event)
    {
        Console.WriteLine($"Received event with message: {@event.Message}");
        return Task.CompletedTask;
    }
}

[EventType]
public record TestEvent(string Message);
