var builder = DistributedApplication.CreateBuilder(args);

var chronicle = builder.AddCratisChronicle("chronicle");

builder.AddProject<Projects.CratisAspire_CratisAspire>("backend")
    .WithReference(chronicle)
    .WaitFor(chronicle);

builder.Build().Run();
