package extension

import kotlin.test.Test
import kotlin.test.assertEquals

class GreeterTest {
    @Test
    fun `uses the configured greeting`() {
        assertEquals(GreetResult.Returned("""{"message":"Welcome, Ada!"}"""), Greeter.greet("Welcome", """{"name":"Ada"}"""))
    }

    @Test
    fun `uses the default greeting when none is configured`() {
        assertEquals(GreetResult.Returned("""{"message":"Hello, Ada!"}"""), Greeter.greet(null, """{"name":"Ada"}"""))
    }

    @Test
    fun `is not sent when the input has no name so it is safe to try again`() {
        assertEquals(GreetResult.Invalid("The input has no name."), Greeter.greet(null, "{}"))
    }
}
