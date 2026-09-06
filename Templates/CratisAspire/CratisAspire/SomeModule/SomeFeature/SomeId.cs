// Copyright (c) Cratis. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

namespace CratisAspire.SomeModule.SomeFeature;

/// <summary>
/// Represents the identity of an item registered in this feature.
/// </summary>
/// <param name="Value">The underlying identifier.</param>
public record SomeId(Guid Value) : EventSourceId<Guid>(Value)
{
    /// <summary>
    /// Represents an unset identity.
    /// </summary>
    public static readonly SomeId NotSet = new(Guid.Empty);

    /// <summary>
    /// Creates a new identity.
    /// </summary>
    /// <returns>A new <see cref="SomeId"/>.</returns>
    public static SomeId New() => new(Guid.NewGuid());

    /// <summary>
    /// Converts a <see cref="Guid"/> to an identity.
    /// </summary>
    /// <param name="value">The identifier to convert.</param>
    public static implicit operator SomeId(Guid value) => new(value);
}
