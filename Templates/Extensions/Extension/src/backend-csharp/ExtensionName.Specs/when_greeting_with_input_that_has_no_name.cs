using Cratis.Stage.Extensions;

namespace ExtensionName.Specs;

public class when_greeting_with_input_that_has_no_name : Specification
{
    AbilityOutcome _outcome = null!;

    void Because() => _outcome = Greeter.Greet(null, "{}");

    [Fact] void should_not_send_it_so_it_is_safe_to_try_again() => _outcome.ShouldEqual(AbilityOutcome.NotSent("The input has no name."));
}
