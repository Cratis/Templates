package main

import (
	"errors"
	"testing"
)

func TestGreetingUsesTheConfiguredGreeting(t *testing.T) {
	output, err := Greet("Welcome", `{"name":"Ada"}`)
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
	if output != `{"message":"Welcome, Ada!"}` {
		t.Fatalf("unexpected output %s", output)
	}
}

func TestGreetingWithoutAConfiguredGreetingUsesTheDefault(t *testing.T) {
	output, err := Greet("", `{"name":"Ada"}`)
	if err != nil {
		t.Fatalf("expected no error, got %v", err)
	}
	if output != `{"message":"Hello, Ada!"}` {
		t.Fatalf("unexpected output %s", output)
	}
}

func TestGreetingWithInputThatHasNoNameIsRejected(t *testing.T) {
	_, err := Greet("", `{}`)
	if !errors.Is(err, ErrInvalidInput) {
		t.Fatalf("expected ErrInvalidInput, got %v", err)
	}
}
