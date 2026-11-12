using Cratis.Stage.Extensions;

namespace ExtensionName.Specs;

public class when_greeting_without_a_configured_greeting : Specification
{
    AbilityOutcome _outcome = null!;

    void Because() => _outcome = Greeter.Greet(null, """{"name":"Ada"}""");

    [Fact] void should_use_the_default_greeting() => _outcome.ShouldEqual(AbilityOutcome.Returned("""{"message":"Hello, Ada!"}"""));
}
