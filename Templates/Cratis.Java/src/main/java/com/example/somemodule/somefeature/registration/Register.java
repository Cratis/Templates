// Copyright (c) Cratis. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

package com.example.somemodule.somefeature.registration;

import com.example.somemodule.somefeature.SomeId;
import com.example.somemodule.somefeature.SomeName;
import io.cratis.arc.artifacts.Command;
import io.cratis.arc.artifacts.CommandKey;
import io.cratis.arc.authorization.AllowAnonymous;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.CompletionStage;

/**
 * Represents a command for registering something in the domain.
 * @param id The unique identifier of the thing being registered - the event source key.
 * @param name The name to register.
 */
@Command
@AllowAnonymous
public record Register(@CommandKey SomeId id, SomeName name) {
    /** @return The server-handled event through Arc's Java asynchronous command path. */
    public CompletionStage<Registered> handle() {
        return CompletableFuture.completedFuture(new Registered(name()));
    }
}
