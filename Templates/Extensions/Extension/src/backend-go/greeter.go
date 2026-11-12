package main

import (
	"encoding/json"
	"errors"
	"strings"
)

// DefaultGreeting is used when the public greeting setting is not set.
const DefaultGreeting = "Hello"

// ErrInvalidInput says the ability input is not what contract.play declares. Nothing has happened when it is
// returned, so the call can safely be sent again.
var ErrInvalidInput = errors.New("the input has no name")

// Greet is the sample ability. It is plain code with no host in it, so a test can call it directly. Replace it
// with the ability your extension realizes, keeping it in step with contract.play.
//
// greeting is the value of the public greeting setting, empty when it is not set. inputJSON is the ability
// input: {"name": "Ada"}. The result is the ability output as JSON.
func Greet(greeting string, inputJSON string) (string, error) {
	var input struct {
		Name string `json:"name"`
	}
	if err := json.Unmarshal([]byte(inputJSON), &input); err != nil || strings.TrimSpace(input.Name) == "" {
		return "", ErrInvalidInput
	}

	if strings.TrimSpace(greeting) == "" {
		greeting = DefaultGreeting
	}

	output, err := json.Marshal(map[string]string{"message": greeting + ", " + input.Name + "!"})
	if err != nil {
		return "", err
	}
	return string(output), nil
}
