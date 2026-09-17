// Copyright (c) Cratis. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

package com.example.somemodule.somefeature.registration

import com.example.somemodule.somefeature.SomeId
import com.example.somemodule.somefeature.SomeName
import io.cratis.arc.artifacts.Command
import io.cratis.arc.artifacts.CommandKey
import io.cratis.arc.authorization.AllowAnonymous
import io.cratis.chronicle.events.EventType
import io.cratis.chronicle.observation.Reactor
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Component

/**
 * Represents a command for registering something in the domain.
 * @param id The unique identifier of the thing being registered - the event source key.
 * @param name The name to register.
 */
@Command
@AllowAnonymous
data class Register(
    @CommandKey val id: SomeId,
    val name: SomeName
) {
    /**
     * Handles the command by producing the event to append to the command-key event source.
     * @return The [Registered] event to append.
     */
    fun handle(): Registered = Registered(name)
}

/**
 * Represents the fact that something was registered.
 * @param name The name it was registered with.
 */
@EventType
data class Registered(val name: SomeName = SomeName(""))

/**
 * Represents a reactor observing [Registered] events to perform side effects.
 */
@Component
@Reactor
class RegistrationReactor {
    private val logger = LoggerFactory.getLogger(RegistrationReactor::class.java)

    /**
     * Called when something was registered.
     * @param event The [Registered] event.
     */
    fun registered(event: Registered) {
        logger.info("Registered: {}", event.name.value)
    }
}
