// Copyright (c) Cratis. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

package com.example.somemodule.somefeature

import io.cratis.chronicle.concepts.ConceptAs as ChronicleConceptAs
import io.cratis.fundamentals.concepts.ConceptAs

/**
 * Represents the name of something in the domain.
 *
 * A concept implements the Fundamentals contract (the method shape Arc reads)
 * and Chronicle's contract (the property shape the Chronicle client serializer
 * reads) so the value flows through commands, events, and read models alike.
 */
data class SomeName(private val name: String) : ConceptAs<String>, ChronicleConceptAs<String> {
    /** @return The wrapped name, as read by Arc. */
    override fun value(): String = name

    /** The wrapped name, as read by the Chronicle client. */
    override val value: String get() = name
}
