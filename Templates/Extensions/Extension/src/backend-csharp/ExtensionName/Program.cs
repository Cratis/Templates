using System.Net;
using Cratis.Stage.Extensions;
using ExtensionName;

// Stage tells the backend where to listen. The default serves running it by hand.
var listen = Environment.GetEnvironmentVariable("STAGE_EXTENSION_LISTEN") ?? "0.0.0.0:50051";

// Everything declared here is checked against contract.play when Stage connects.
var extension = Extension.Create("ExtensionName", "1.0.0")
    .Setting(Greeter.GreetingSetting)
    .Ability(
        Greeter.AbilityName,
        EffectClass.Safe,
        async call => Greeter.Greet(await call.Host.Setting(Greeter.GreetingSetting, call.CancellationToken), call.Input))
    .Build();

await ExtensionRunner.Run(extension, IPEndPoint.Parse(listen));
