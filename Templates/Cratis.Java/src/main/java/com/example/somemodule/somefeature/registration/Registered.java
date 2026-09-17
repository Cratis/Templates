// Copyright (c) Cratis. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

package com.example.somemodule.somefeature.registration;

import com.example.somemodule.somefeature.SomeName;
import io.cratis.chronicle.events.EventType;

/** Represents the fact that something was registered. */
@EventType
public record Registered(SomeName name) {}
