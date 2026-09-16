// Copyright (c) Cratis. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

package com.example

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

/**
 * The application entry point.
 */
@SpringBootApplication
class CratisAppApplication

/**
 * Runs the application.
 * @param args The command line arguments.
 */
fun main(args: Array<String>) {
    runApplication<CratisAppApplication>(*args)
}
