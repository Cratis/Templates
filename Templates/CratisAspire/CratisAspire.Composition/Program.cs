using Cratis.Chronicle.Aspire;

var builder = DistributedApplication.CreateBuilder(args);

#if cratisMongoDb
var chronicle = builder.AddCratisChronicle();
#endif
#if cratisPostgreSql
var database = builder.AddPostgres("database").AddDatabase("Cratis");
var chronicle = builder.AddCratisChronicle(configure: chronicleBuilder => chronicleBuilder.WithPostgreSql(database));
#endif
#if cratisMsSql
var database = builder.AddSqlServer("database").AddDatabase("Cratis");
var chronicle = builder.AddCratisChronicle(configure: chronicleBuilder => chronicleBuilder.WithMsSql(database));
#endif
#if cratisSqlite
var chronicle = builder
    .AddCratisChronicle(configure: chronicleBuilder => chronicleBuilder.WithSqlite("Data Source=/data/chronicle.db"))
    .WithDataVolume("chronicle-data");
#endif

builder.AddProject<Projects.CratisAspire>("backend")
    .WithReference(chronicle)
#if cratisPostgreSql || cratisMsSql
    .WithReference(database)
#endif
    .WaitFor(chronicle);

builder.Build().Run();
