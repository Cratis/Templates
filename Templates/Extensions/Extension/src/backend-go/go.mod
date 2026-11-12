module PUBLISHER/EXTENSION_KEBAB

go 1.26.0

// The backend SDK: the extension protocol, the handshake against contract.play and the host services.
// Until it has a release tag, scripts/build.sh and scripts/test.sh replace it with a clone of Cratis/Stage
// when CRATIS_STAGE_SDK points at one. See README.md.
require github.com/Cratis/Stage/Source/Extensions/Go v1.0.0
