package main

import (
	"context"
	"errors"
	"log"
	"net"
	"os"

	"github.com/Cratis/Stage/Source/Extensions/Go/extension"
)

const (
	abilityName     = "Greet"
	greetingSetting = "greeting"
)

func main() {
	// Stage tells the backend where to listen. The default serves running it by hand.
	listen := os.Getenv("STAGE_EXTENSION_LISTEN")
	if listen == "" {
		listen = "0.0.0.0:50051"
	}

	// Everything declared here is checked against contract.play when Stage connects.
	extensionBackend := extension.New("ExtensionName", "1.0.0").
		Setting(greetingSetting, false).
		Ability(abilityName, extension.Safe, func(ctx context.Context, call *extension.Call) (extension.Outcome, error) {
			greeting, _, err := call.Host.Setting(ctx, greetingSetting)
			if err != nil {
				return extension.Outcome{}, err
			}

			output, err := Greet(greeting, call.Input)
			if errors.Is(err, ErrInvalidInput) {
				return extension.NotSent(err.Error()), nil
			}
			if err != nil {
				return extension.Outcome{}, err
			}
			return extension.Returned(output, ""), nil
		})

	listener, err := net.Listen("tcp", listen)
	if err != nil {
		log.Fatal(err)
	}
	log.Fatal(extensionBackend.Serve(listener))
}
