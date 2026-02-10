using Cratis.Chronicle;
using Cratis.Chronicle.Connections;

Console.WriteLine("Starting Chronicle Web App...");
var app = WebApplication.CreateBuilder(args)
    .AddCratisChronicle(_ => _.ConnectionString = ChronicleConnectionString.Development)
    .Build();

app.UseCratisChronicle();

using var serviceScope = app.Services.CreateScope();
var services = serviceScope.ServiceProvider;
var eventStore = services.GetRequiredService<IEventStore>();
Console.WriteLine("Appending event");
await eventStore.EventLog.Append("some-event-source", new TestEvent("Hello world!"));

app.Run();
