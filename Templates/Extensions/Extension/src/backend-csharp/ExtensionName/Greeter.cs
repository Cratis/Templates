using System.Text.Json;
using Cratis.Stage.Extensions;

namespace ExtensionName;

/// <summary>
/// The sample ability. It is plain code with no host in it, so a specification can call it directly.
/// Replace it with the ability your extension realizes, keeping it in step with <c>contract.play</c>.
/// </summary>
public static class Greeter
{
    /// <summary>The name of the ability, as <c>contract.play</c> declares it.</summary>
    public const string AbilityName = "Greet";

    /// <summary>The name of the public setting that holds the greeting.</summary>
    public const string GreetingSetting = "greeting";

    const string DefaultGreeting = "Hello";

    /// <summary>
    /// Greets the name in the input.
    /// </summary>
    /// <param name="greeting">The value of the public <c>greeting</c> setting, or null when it is not set.</param>
    /// <param name="inputJson">The ability input as JSON: <c>{ "name": "Ada" }</c>.</param>
    /// <returns>
    /// <c>Returned</c> with the message, or <c>NotSent</c> when the input is not what the contract declares. Nothing has
    /// happened in that case, so Stage can safely send the same call again.
    /// </returns>
    public static AbilityOutcome Greet(string? greeting, string inputJson)
    {
        string? name;
        try
        {
            using var input = JsonDocument.Parse(inputJson);
            name = input.RootElement.TryGetProperty("name", out var value) && value.ValueKind == JsonValueKind.String
                ? value.GetString()
                : null;
        }
        catch (JsonException)
        {
            return AbilityOutcome.NotSent("The input is not JSON.");
        }

        if (string.IsNullOrWhiteSpace(name))
        {
            return AbilityOutcome.NotSent("The input has no name.");
        }

        var message = $"{(string.IsNullOrWhiteSpace(greeting) ? DefaultGreeting : greeting)}, {name}!";
        return AbilityOutcome.Returned(JsonSerializer.Serialize(new { message }));
    }
}
