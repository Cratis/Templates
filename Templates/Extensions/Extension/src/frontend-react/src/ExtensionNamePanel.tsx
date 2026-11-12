import { useState } from 'react';
import { reactComponent, useInvoke, useLocale, useRaise, useUser } from '@cratis/scene.extensions';

/** The properties contract.play declares for the component. */
export interface ExtensionNamePanelProperties {
    label: string;
}

/**
 * The sample component. It reads the user and the locale through the hooks, calls the Greet ability through the
 * host and raises the greeted signal. Replace it with your own, keeping it in step with contract.play.
 */
export function ExtensionNamePanelView({ label }: ExtensionNamePanelProperties) {
    const user = useUser();
    const locale = useLocale();
    const invoke = useInvoke();
    const raise = useRaise();
    const [message, setMessage] = useState('');

    const greet = async () => {
        const result = (await invoke('Greet', { name: user.name })) as { message: string };
        setMessage(result.message);
        raise('greeted', { message: result.message });
    };

    return (
        <section>
            <p data-summary>{`${label}|${user.name}|${locale.language}`}</p>
            <button type="button" onClick={greet}>Greet</button>
            <p data-message>{message}</p>
        </section>
    );
}

export const ExtensionNamePanel = reactComponent(ExtensionNamePanelView);
