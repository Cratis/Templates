package extension

import com.google.gson.JsonObject
import com.google.gson.JsonParseException
import com.google.gson.JsonParser

/** What the sample ability answers: the output as JSON, or a reason it cannot answer. */
sealed interface GreetResult {
    data class Returned(val output: String) : GreetResult

    /** The input is not what contract.play declares. Nothing has happened, so the call can safely be sent again. */
    data class Invalid(val reason: String) : GreetResult
}

/**
 * The sample ability. It is plain code with no host in it, so a test can call it directly. Replace it with the
 * ability your extension realizes, keeping it in step with contract.play.
 */
object Greeter {
    const val DEFAULT_GREETING = "Hello"

    /**
     * Greets the name in the input.
     *
     * @param greeting the value of the public greeting setting, or null when it is not set
     * @param inputJson the ability input as JSON: `{ "name": "Ada" }`
     */
    fun greet(greeting: String?, inputJson: String): GreetResult {
        val name = try {
            val root = JsonParser.parseString(inputJson)
            if (root.isJsonObject) root.asJsonObject.get("name")?.takeIf { it.isJsonPrimitive }?.asString else null
        } catch (_: JsonParseException) {
            return GreetResult.Invalid("The input is not JSON.")
        }

        if (name.isNullOrBlank()) {
            return GreetResult.Invalid("The input has no name.")
        }

        val output = JsonObject()
        output.addProperty("message", "${greeting?.takeIf { it.isNotBlank() } ?: DEFAULT_GREETING}, $name!")
        return GreetResult.Returned(output.toString())
    }
}
