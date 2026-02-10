using Cratis.Chronicle;

Console.WriteLine("Starting Chronicle Console App...");

using var client = new ChronicleClient();
var eventStore = await client.GetEventStore("ChronicleConsole");

Console.WriteLine("Appending event");
await eventStore.EventLog.Append("some-event-source", new TestEvent("Hello world!"));

Console.ReadKey();
