var builder = WebApplication.CreateBuilder(args);
builder.AddServiceDefaults();
#if cratisMongoDb
builder.AddCratis(
    configureChronicleBuilder: chronicleBuilder => chronicleBuilder.WithCamelCaseNamingPolicy(),
    configureArcBuilder: arcBuilder => arcBuilder.WithMongoDB(configureMongoDB: mongoBuilder => mongoBuilder.WithCamelCaseNamingPolicy()));
#else
// Chronicle's SQL sink names tables and columns after the read model (Listings, Id, Name), which is
// what Entity Framework Core maps by default, so the camel-case naming policy is left out here.
builder.AddCratis(
    configureArcBuilder: arcBuilder => arcBuilder.WithEntityFrameworkCore(options => options.ConnectionString =
        builder.Configuration.GetConnectionString("Cratis")!));
#endif

builder.Services.AddControllers();
builder.Services.AddMvc();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options => options.AddConcepts());

var app = builder.Build();

app.UseRouting();

app.UseDefaultFiles();
app.UseStaticFiles();

app.UseWebSockets();
app.MapControllers();
app.UseCratis();

app.UseSwagger();
app.UseSwaggerUI();
app.MapDefaultEndpoints();
app.MapFallbackToFile("/index.html");

await app.RunAsync();
