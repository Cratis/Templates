var builder = DistributedApplication.CreateBuilder(args);

var chronicle = builder.AddCratisChronicle();

builder.AddProject<Projects.CratisAspire>("backend")
    .WithReference(chronicle)
    .WaitFor(chronicle);

builder.Build().Run();
