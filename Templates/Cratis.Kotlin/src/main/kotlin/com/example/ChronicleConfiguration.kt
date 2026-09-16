// Copyright (c) Cratis. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

package com.example

import com.example.somemodule.somefeature.listing.Listing
import com.example.somemodule.somefeature.listing.ListingReducer
import com.example.somemodule.somefeature.registration.Registered
import com.example.somemodule.somefeature.registration.RegistrationReactor
import io.cratis.chronicle.ChronicleOptions
import io.cratis.chronicle.artifacts.IArtifactActivator
import io.cratis.chronicle.artifacts.KnownClientArtifacts
import io.cratis.chronicle.connection.ChronicleConnectionString
import io.cratis.chronicle.sinks.WellKnownSinkTypes
import io.cratis.chronicle.spring.ChronicleProperties
import org.springframework.beans.factory.annotation.Value
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

/**
 * Declares the Chronicle options with an explicit artifact list so executable
 * Spring Boot jars register the same domain contract as exploded development runs.
 */
@Configuration(proxyBeanMethods = false)
class ChronicleConfiguration {
    /**
     * Builds the [ChronicleOptions] from configuration and the domain contract.
     * @param properties The Chronicle configuration properties.
     * @param artifactActivator The artifact activator for registering artifacts.
     * @param applicationName The Spring application name.
     * @return The Chronicle options to run with.
     */
    @Bean
    fun chronicleOptions(
        properties: ChronicleProperties,
        artifactActivator: IArtifactActivator,
        @Value("\${spring.application.name:Unknown}") applicationName: String
    ): ChronicleOptions = ChronicleOptions(
        connectionString = ChronicleConnectionString.parse(properties.connectionString),
        programIdentifier = properties.programIdentifier ?: applicationName,
        defaultSinkTypeId = properties.defaultSinkTypeId
            ?: System.getenv("CHRONICLE_SINK_TYPE")
            ?: WellKnownSinkTypes.MONGODB,
        autoDiscoverAndRegister = properties.autoDiscoverAndRegister,
        artifacts = KnownClientArtifacts(
            Registered::class,
            Listing::class,
            ListingReducer::class,
            RegistrationReactor::class
        ),
        artifactActivator = artifactActivator
    )
}
