/** The default greeting, used when the public greeting setting is not set. */
export const defaultGreeting = 'Hello';

/** What the sample ability answers: the output as JSON, or a reason it cannot answer. */
export type GreetResult = { readonly kind: 'returned'; readonly output: string } | { readonly kind: 'invalid'; readonly reason: string };

/**
 * The sample ability. It is plain code with no host in it, so a test can call it directly. Replace it with the
 * ability your extension realizes, keeping it in step with contract.play.
 *
 * @param greeting The value of the public greeting setting, or undefined when it is not set.
 * @param inputJson The ability input as JSON: `{ "name": "Ada" }`.
 */
export function greet(greeting: string | undefined, inputJson: string): GreetResult {
    let name: unknown;
    try {
        name = (JSON.parse(inputJson) as { name?: unknown }).name;
    } catch {
        return { kind: 'invalid', reason: 'The input is not JSON.' };
    }

    if (typeof name !== 'string' || name.trim() === '') {
        return { kind: 'invalid', reason: 'The input has no name.' };
    }

    const message = `${greeting?.trim() ? greeting : defaultGreeting}, ${name}!`;
    return { kind: 'returned', output: JSON.stringify({ message }) };
}
