using Cratis.Chronicle.Reactors;

public class TestReactor : IReactor
{
    public Task React(TestEvent @event)
    {
        Console.WriteLine($"Received event with message: {@event.Message}");
        return Task.CompletedTask;
    }
}
