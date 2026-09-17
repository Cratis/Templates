// Copyright (c) Cratis. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

package com.example.somemodule.somefeature.listing;

import com.example.somemodule.somefeature.registration.Registered;
import io.cratis.chronicle.events.EventContext;
import io.cratis.chronicle.observation.Reducer;

/** Represents a reducer building Listing from Registered events. */
@Reducer
public final class ListingReducer {
    /**
     * Called when something was registered.
     * @param event The registered event.
     * @param state The current state, if any.
     * @param context The event context carrying the event source key.
     * @return The next state.
     */
    public Listing registered(Registered event, Listing state, EventContext context) {
        return new Listing(context.getEventSourceId(), event.name());
    }
}
