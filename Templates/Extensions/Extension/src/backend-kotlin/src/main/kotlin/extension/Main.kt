package extension

import io.cratis.stage.extensions.AbilityOutcome
import io.cratis.stage.extensions.EffectClass
import io.cratis.stage.extensions.Extension

fun main() {
    // Stage tells the backend where to listen. The default serves running it by hand.
    val listen = System.getenv("STAGE_EXTENSION_LISTEN") ?: "0.0.0.0:50051"
    val host = listen.substringBeforeLast(':')
    val port = listen.substringAfterLast(':').toInt()

    // Everything declared here is checked against contract.play when Stage connects.
    val extension = Extension.create("ExtensionName", "1.0.0")
        .setting("greeting")
        .ability("Greet", EffectClass.Safe) { call ->
            when (val result = Greeter.greet(call.host.setting("greeting"), call.input)) {
                is GreetResult.Returned -> AbilityOutcome.Returned(result.output)
                is GreetResult.Invalid -> AbilityOutcome.NotSent(result.reason)
            }
        }

    val server = extension.listen(port, host).start()
    println("ExtensionName listening on ${server.port}")
    server.awaitTermination()
}
