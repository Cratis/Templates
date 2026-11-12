using Cratis.Stage.Extensions;

namespace ExtensionName.Specs;

public class when_greeting : Specification
{
    AbilityOutcome _outcome = null!;

    void Because() => _outcome = Greeter.Greet("Welcome", """{"name":"Ada"}""");

    [Fact] void should_return_the_message() => _outcome.ShouldEqual(AbilityOutcome.Returned("""{"message":"Welcome, Ada!"}"""));
}
