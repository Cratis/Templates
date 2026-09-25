using Cratis.Chronicle.Aspire;

var builder = DistributedApplication.CreateBuilder(args);

// Every database choice runs the Chronicle development image: it creates the development client
// credentials the backend connects with and a self-signed certificate. Do not use it in production.

#if cratisMongoDb
// The development image runs MongoDB inside the Chronicle container. Exposing it lets the backend
// read the read models Chronicle projects there.
var chronicle = builder
    .AddCratisChronicle()
    .WithEndpoint(targetPort: 27017, name: "mongodb");
var mongoDB = chronicle.GetEndpoint("mongodb");
#endif
#if cratisPostgreSql
// Chronicle keeps its own data in "chronicle" and projects read models into "chronicle+<event store>",
// which is the database the backend reads through Entity Framework Core.
var postgres = builder.AddPostgres("database");
var chronicleDatabase = postgres.AddDatabase("chronicle-storage", databaseName: "chronicle");
var readModels = postgres.AddDatabase("Cratis", databaseName: "chronicle+CratisAspire");
var chronicle = builder
    .AddCratisChronicle(configure: chronicleBuilder => chronicleBuilder.WithPostgreSql(chronicleDatabase))
    .WithImageTag(ChronicleContainerImageTags.DevelopmentTag)
    .WaitFor(chronicleDatabase);
#endif
#if cratisMsSql
// Chronicle keeps its own data in "chronicle" and projects read models into "chronicle+<event store>",
// which is the database the backend reads through Entity Framework Core.
var sqlServer = builder.AddSqlServer("database");
var chronicleDatabase = sqlServer.AddDatabase("chronicle-storage", databaseName: "chronicle");
var readModels = sqlServer.AddDatabase("Cratis", databaseName: "chronicle+CratisAspire");
var chronicle = builder
    .AddCratisChronicle(configure: chronicleBuilder => chronicleBuilder.WithMsSql(chronicleDatabase))
    .WithImageTag(ChronicleContainerImageTags.DevelopmentTag)
    .WaitFor(chronicleDatabase);
#endif
#if cratisSqlite
// Chronicle writes its SQLite files to a folder on this machine, so the backend can read the
// read models Chronicle projects into chronicle+<event store>.db.
var dataFolder = Path.GetFullPath(Path.Combine(builder.AppHostDirectory, "..", "chronicle-data"));
Directory.CreateDirectory(dataFolder);
var chronicle = builder
    .AddCratisChronicle(configure: chronicleBuilder => chronicleBuilder.WithSqlite("Data Source=/data/chronicle.db"))
    .WithImageTag(ChronicleContainerImageTags.DevelopmentTag)
    .WithBindMount(dataFolder, "/data");
#endif

// The Chronicle client reads Cratis:Chronicle:ConnectionString rather than Aspire's ConnectionStrings,
// so hand it the address Aspire assigned, with the development client credentials.
var chronicleGrpc = chronicle.GetEndpoint("grpc");

builder.AddProject<Projects.CratisAspire>("backend")
    .WithReference(chronicle)
    .WithEnvironment(
        "Cratis__Chronicle__ConnectionString",
        ReferenceExpression.Create($"chronicle://chronicle-dev-client:chronicle-dev-secret@{chronicleGrpc.Property(EndpointProperty.Host)}:{chronicleGrpc.Property(EndpointProperty.Port)}"))
#if cratisMongoDb
    .WithEnvironment(
        "Cratis__MongoDB__Server",
        ReferenceExpression.Create($"mongodb://{mongoDB.Property(EndpointProperty.Host)}:{mongoDB.Property(EndpointProperty.Port)}/?directConnection=true"))
#endif
#if (cratisPostgreSql || cratisMsSql)
    .WithReference(readModels)
    .WaitFor(readModels)
#endif
#if cratisSqlite
    .WithEnvironment("ConnectionStrings__Cratis", $"Data Source={Path.Combine(dataFolder, "chronicle+CratisAspire.db")}")
#endif
    .WaitFor(chronicle);

builder.Build().Run();
