using Cratis.OpenTelemetry;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Diagnostics.HealthChecks;

namespace Microsoft.Extensions.Hosting;

/// <summary>
/// Provides extension methods for configuring shared service defaults used across all services in the application.
/// </summary>
public static class Extensions
{
    /// <summary>
    /// Adds common service defaults including OpenTelemetry, health checks, and service discovery.
    /// </summary>
    /// <param name="builder">The <see cref="IHostApplicationBuilder"/> to configure.</param>
    /// <returns>The <see cref="IHostApplicationBuilder"/> for chaining.</returns>
    public static IHostApplicationBuilder AddServiceDefaults(this IHostApplicationBuilder builder)
    {
        builder.ConfigureOpenTelemetry();
        builder.AddDefaultHealthChecks();

        builder.Services.AddServiceDiscovery();

        builder.Services.ConfigureHttpClientDefaults(http =>
        {
            http.AddStandardResilienceHandler();
            http.AddServiceDiscovery();
        });

        return builder;
    }

    /// <summary>
    /// Configures OpenTelemetry for metrics, tracing, and logging through the shared Cratis setup.
    /// </summary>
    /// <remarks>
    /// Subscribes to every Cratis activity source and meter, adds ASP.NET Core, HTTP client and runtime
    /// instrumentation, and exports over OTLP only when an endpoint such as OTEL_EXPORTER_OTLP_ENDPOINT
    /// is configured, which Aspire does for every project it starts.
    /// </remarks>
    /// <param name="builder">The <see cref="IHostApplicationBuilder"/> to configure.</param>
    /// <returns>The <see cref="IHostApplicationBuilder"/> for chaining.</returns>
    public static IHostApplicationBuilder ConfigureOpenTelemetry(this IHostApplicationBuilder builder) =>
        builder.AddCratisOpenTelemetry(options => options.ServiceName = builder.Environment.ApplicationName);

    /// <summary>
    /// Adds default health check registrations.
    /// </summary>
    /// <param name="builder">The <see cref="IHostApplicationBuilder"/> to configure.</param>
    /// <returns>The <see cref="IHostApplicationBuilder"/> for chaining.</returns>
    public static IHostApplicationBuilder AddDefaultHealthChecks(this IHostApplicationBuilder builder)
    {
        builder.Services.AddHealthChecks()
            .AddCheck("self", () => HealthCheckResult.Healthy(), ["live"]);

        return builder;
    }

    /// <summary>
    /// Maps default health check and liveness endpoints for development environments only.
    /// </summary>
    /// <param name="app">The <see cref="WebApplication"/> to map endpoints on.</param>
    /// <returns>The <see cref="WebApplication"/> for chaining.</returns>
    public static WebApplication MapDefaultEndpoints(this WebApplication app)
    {
        if (app.Environment.IsDevelopment())
        {
            app.MapHealthChecks("/health");
            app.MapHealthChecks("/alive", new HealthCheckOptions
            {
                Predicate = r => r.Tags.Contains("live")
            });
        }

        return app;
    }
}
