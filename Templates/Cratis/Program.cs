using CratisApp.Features.SomeFeature.Registration;

var builder = WebApplication.CreateBuilder(args);
builder.AddCratis();

builder.Services.AddControllers();
builder.Services.AddMvc();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options => options.AddConcepts());

var app = builder.Build();
app.UseRouting();
app.UseCratis();

app.MapControllers();
app.UseWebSockets();

app.UseSwagger();
app.UseSwaggerUI();

app.UseDefaultFiles();
app.UseStaticFiles();
app.MapFallbackToFile("/index.html");

await app.RunAsync();


public class RegistrationReactor(ILogger<RegistrationReactor> logger) : IReactor
{
    public Task Handle(Registered evt)
    {
        logger.LogInformation("Registered: {Name}", evt.Name);
        return Task.CompletedTask;
    }
}