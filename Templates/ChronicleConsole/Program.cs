using Cratis.Chronicle;
using Cratis.Chronicle.Events;
using Cratis.Chronicle.Projections.ModelBound;
using Cratis.Chronicle.Reactors;

using var client = new ChronicleClient();
var eventStore = await client.GetEventStore("ChronicleConsole");

await eventStore.EventLog.Append("some-event-source", new TestEvent("Hello world!"));

Console.ReadKey();

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
