// Copyright (c) Cratis. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

package com.example.somemodule.somefeature.registration;

import io.cratis.chronicle.events.EventType;
import io.cratis.chronicle.observation.Reactor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

/** Represents a reactor observing Registered events to perform side effects. */
@Component
@Reactor
public class RegistrationReactor {
    private static final Logger LOG = LoggerFactory.getLogger(RegistrationReactor.class);

    /**
     * Called when something was registered.
     * @param event The registered event.
     */
    public void registered(Registered event) {
        LOG.info("Registered: {}", event.name().getValue());
    }
}
