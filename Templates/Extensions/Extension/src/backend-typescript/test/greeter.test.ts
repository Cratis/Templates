import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import { greet } from '../src/greeter.js';

describe('greeting', () => {
    it('uses the configured greeting', () => {
        assert.deepEqual(greet('Welcome', '{"name":"Ada"}'), { kind: 'returned', output: '{"message":"Welcome, Ada!"}' });
    });

    it('uses the default greeting when none is configured', () => {
        assert.deepEqual(greet(undefined, '{"name":"Ada"}'), { kind: 'returned', output: '{"message":"Hello, Ada!"}' });
    });

    it('is not sent when the input has no name, so it is safe to try again', () => {
        assert.deepEqual(greet(undefined, '{}'), { kind: 'invalid', reason: 'The input has no name.' });
    });
});
