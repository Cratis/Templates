Console.WriteLine("Starting Chronicle Web App...");
var app = WebApplication.CreateBuilder(args)
    .AddCratisChronicle()
    .Build();

app.UseCratisChronicle();

await app.RunAsync();
