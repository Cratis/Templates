import { act } from 'react';
import { describe, expect, it, vi } from 'vitest';
import { createExtensionConformanceChecks, createExtensionContext, mountExtensionComponent } from '@cratis/scene.extensions';
import { ExtensionNamePanel } from '../src/ExtensionNamePanel';

const summaryOf = (host: HTMLElement) => host.querySelector('[data-summary]')?.textContent;

// The conformance kit is what Scene holds every extension component to, whatever its kind.
describe('ExtensionNamePanel conformance', () => {
    const checks = createExtensionConformanceChecks({
        name: 'ExtensionNamePanel',
        definition: ExtensionNamePanel,
        properties: { label: 'Hello' },
        updatedProperties: { label: 'Welcome' },
        verify: (host, expected) => {
            const wanted = `${expected.properties.label}|${expected.user.name}|${expected.locale.language}`;
            if (summaryOf(host) !== wanted) {
                throw new Error(`Expected '${wanted}' but the host shows '${summaryOf(host)}'.`);
            }
        }
    });

    for (const check of checks) {
        it(`should ${check.name}`, check.run);
    }
});

describe('ExtensionNamePanel greeting', () => {
    it('should raise greeted with a greeting for the user', async () => {
        (globalThis as { IS_REACT_ACT_ENVIRONMENT?: boolean }).IS_REACT_ACT_ENVIRONMENT = true;
        const raise = vi.fn();
        const { context } = createExtensionContext({ user: { id: 'u1', name: 'Ada', roles: [], signedIn: true }, raise });
        const host = document.createElement('div');
        document.body.appendChild(host);

        let instance!: ReturnType<typeof mountExtensionComponent>;
        await act(async () => { instance = mountExtensionComponent(ExtensionNamePanel, host, { label: 'Hello' }, context); });
        await act(async () => { host.querySelector('button')!.click(); });

        expect(raise).toHaveBeenCalledWith('greeted', { message: 'Hello, Ada!' });
        expect(host.querySelector('[data-message]')?.textContent).toBe('Hello, Ada!');

        await act(async () => { instance.unmount(); });
        host.remove();
    });
});
