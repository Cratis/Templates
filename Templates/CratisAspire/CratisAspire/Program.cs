var builder = WebApplication.CreateBuilder(args);
builder.AddServiceDefaults();
builder.AddCratis(
    configureArcChronicleOptions: options => options.WithCamelCaseNamingPolicy(),
    configureArcBuilder: arcBuilder => arcBuilder.WithMongoDB(configureMongoDB: builder => builder.WithCamelCaseNamingPolicy()));

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
