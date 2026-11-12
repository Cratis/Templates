import { useState } from 'react';
import { reactComponent, useLocale, useRaise, useUser } from '@cratis/scene.extensions';

/** The properties contract.play declares for the component. */
export interface ExtensionNamePanelProperties {
    label: string;
}

/**
 * The sample component. It reads the user and the locale through the hooks and raises the greeted signal. Replace it
 * with your own, keeping it in step with contract.play.
 */
export function ExtensionNamePanelView({ label }: ExtensionNamePanelProperties) {
    const user = useUser();
    const locale = useLocale();
    const raise = useRaise();
    const [message, setMessage] = useState('');

    const greet = () => {
        const greeting = `${label}, ${user.name}!`;
        setMessage(greeting);
        raise('greeted', { message: greeting });
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
