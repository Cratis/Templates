// Copyright (c) Cratis. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

package com.example.somemodule.somefeature.listing;

import com.example.somemodule.somefeature.SomeName;
import io.cratis.arc.artifacts.FromServices;
import io.cratis.arc.authorization.AllowAnonymous;
import io.cratis.arc.queries.Path;
import io.cratis.chronicle.spring.Chronicle;
import java.util.List;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.CompletionStage;

/**
 * Represents a read model projected from registered things.
 * @param id The unique identifier of the thing - its event source key.
 * @param name The name it was registered with.
 */
@io.cratis.arc.artifacts.ReadModel
@io.cratis.chronicle.readModels.ReadModel
@AllowAnonymous
public record Listing(String id, SomeName name) {
    /**
     * Query for getting all listings.
     * @param chronicle The Chronicle facade for blocking reads.
     * @return All projected listings.
     */
    @Path("/api/listings")
    public static CompletionStage<List<Listing>> all(@FromServices Chronicle chronicle) {
        return CompletableFuture.completedFuture(chronicle.readModels(Listing.class));
    }
}
