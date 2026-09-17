// Copyright (c) Cratis. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

package com.example.somemodule.somefeature;

import io.cratis.arc.concepts.ConceptAs;

/**
 * Represents the unique identifier of something in the domain.
 *
 * A concept implements Arc's contract (the method shape the Arc tooling reads)
 * and Chronicle's contract (the property shape the Chronicle client serializer
 * reads) so the value flows through commands, events, and read models alike.
 */
public record SomeId(String value) implements ConceptAs<String>, io.cratis.chronicle.concepts.ConceptAs<String> {
    /**
     * The wrapped unique identifier, as read by the Chronicle client.
     * @return The unique identifier.
     */
    @Override
    public String getValue() {
        return value;
    }
}
