import { Extension, outcome } from '@cratis/stage-extensions';
import { greet } from './greeter.js';

// Stage tells the backend where to listen. The default serves running it by hand.
const listen = process.env.STAGE_EXTENSION_LISTEN ?? '0.0.0.0:50051';

// Everything declared here is checked against contract.play when Stage connects.
const extension = Extension.create('ExtensionName', '1.0.0')
    .setting('greeting')
    .ability('Greet', 'safe', async call => {
        const result = greet(await call.host.setting('greeting'), call.input);
        return result.kind === 'returned' ? outcome.returned(result.output) : outcome.notSent(result.reason);
    });

const { port } = await extension.listen(listen);
console.log(`ExtensionName listening on ${port}`);
