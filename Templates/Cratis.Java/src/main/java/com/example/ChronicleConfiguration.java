// Copyright (c) Cratis. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

package com.example;

import com.example.somemodule.somefeature.listing.Listing;
import com.example.somemodule.somefeature.listing.ListingReducer;
import com.example.somemodule.somefeature.registration.Registered;
import com.example.somemodule.somefeature.registration.RegistrationReactor;
import io.cratis.chronicle.ChronicleOptions;
import io.cratis.chronicle.artifacts.IArtifactActivator;
import io.cratis.chronicle.artifacts.KnownClientArtifacts;
import io.cratis.chronicle.connection.ChronicleConnectionString;
import io.cratis.chronicle.sinks.WellKnownSinkTypes;
import io.cratis.chronicle.spring.ChronicleProperties;
import java.util.List;
import kotlin.jvm.JvmClassMappingKt;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Declares the Chronicle options with an explicit artifact list so executable
 * Spring Boot jars register the same domain contract as exploded development runs.
 */
@Configuration(proxyBeanMethods = false)
public class ChronicleConfiguration {
    /**
     * Builds the Chronicle options from configuration and the domain contract.
     * @param properties The Chronicle configuration properties.
     * @param artifactActivator The artifact activator for registering artifacts.
     * @param applicationName The Spring application name.
     * @return The Chronicle options to run with.
     */
    @Bean
    public ChronicleOptions chronicleOptions(
        ChronicleProperties properties,
        IArtifactActivator artifactActivator,
        @Value("${spring.application.name:Unknown}") String applicationName
    ) {
        var artifacts = new KnownClientArtifacts(List.of(
            JvmClassMappingKt.getKotlinClass(Registered.class),
            JvmClassMappingKt.getKotlinClass(Listing.class),
            JvmClassMappingKt.getKotlinClass(ListingReducer.class),
            JvmClassMappingKt.getKotlinClass(RegistrationReactor.class)));
        var sinkType = properties.getDefaultSinkTypeId();
        if (sinkType == null) sinkType = System.getenv("CHRONICLE_SINK_TYPE");
        if (sinkType == null) sinkType = WellKnownSinkTypes.DATABASE_SINK_TYPE;
        var programIdentifier = properties.getProgramIdentifier() == null
            ? applicationName
            : properties.getProgramIdentifier();
        return new ChronicleOptions(
            ChronicleConnectionString.Companion.parse(properties.getConnectionString()),
            programIdentifier,
            sinkType,
            properties.getAutoDiscoverAndRegister(),
            artifacts,
            artifactActivator);
    }
}
