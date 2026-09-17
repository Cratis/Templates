// Copyright (c) Cratis. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

package com.example.somemodule.somefeature

import io.cratis.arc.concepts.ConceptAs as ArcConceptAs
import io.cratis.chronicle.concepts.ConceptAs as ChronicleConceptAs
import java.util.UUID

/**
 * Represents the unique identifier of something in the domain.
 *
 * A concept implements Arc's contract (the method shape the Arc tooling reads)
 * and Chronicle's contract (the property shape the Chronicle client serializer
 * reads) so the value flows through commands, events, and read models alike.
 */
data class SomeId(private val id: String) : ArcConceptAs<String>, ChronicleConceptAs<String> {
    /** @return The wrapped unique identifier, as read by Arc. */
    override fun value(): String = id

    /** The wrapped unique identifier, as read by the Chronicle client. */
    override val value: String get() = id

    /**
     * Creates a new unique [SomeId].
     * @return A new unique identifier.
     */
    companion object {
        /**
         * Creates a new unique [SomeId].
         * @return A new unique identifier.
         */
        fun new(): SomeId = SomeId(UUID.randomUUID().toString())
    }
}
