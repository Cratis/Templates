// Copyright (c) Cratis. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

package com.example.somemodule.somefeature.listing

import com.example.somemodule.somefeature.SomeName
import com.example.somemodule.somefeature.registration.Registered
import io.cratis.arc.artifacts.FromServices
import io.cratis.arc.artifacts.ReadModel as ArcReadModel
import io.cratis.arc.authorization.AllowAnonymous
import io.cratis.arc.queries.Path
import io.cratis.chronicle.IEventStore
import io.cratis.chronicle.events.EventContext
import io.cratis.chronicle.observation.Reducer
import io.cratis.chronicle.readModels.ReadModel as ChronicleReadModel

/**
 * Represents a read model projected from registered things.
 * @param id The unique identifier of the thing - its event source key.
 * @param name The name it was registered with.
 */
@ArcReadModel
@ChronicleReadModel
@AllowAnonymous
data class Listing(
    val id: String = "",
    val name: SomeName = SomeName("")
) {
    /**
     * Query for getting all listings.
     * @param eventStore The event store to read from.
     * @return All projected listings.
     */
    companion object {
        /**
         * Gets all listings.
         * @param eventStore The event store to read from.
         * @return All projected listings.
         */
        @JvmStatic
        @Path("/api/listings")
        suspend fun all(
            @FromServices eventStore: IEventStore
        ): List<Listing> = eventStore.readModels.getInstances(Listing::class)
    }
}

/**
 * Represents a reducer building [Listing] from [Registered] events.
 */
@Reducer
class ListingReducer {
    /**
     * Called when something was registered.
     * @param event The [Registered] event.
     * @param state The current state, if any.
     * @param context The event context carrying the event source key.
     * @return The next state.
     */
    fun registered(event: Registered, state: Listing?, context: EventContext): Listing = Listing(
        id = context.eventSourceId,
        name = event.name
    )
}
