import { mountComponent } from '@cratis/scene.extensions';

/**
 * The sample component. It draws into the host element with plain DOM, so the same body works for Vue, Svelte or
 * Lit: create your app in the host, pass it the properties and the context, and destroy it in unmount. It calls
 * the Greet ability through the host and raises the greeted signal. Replace it with your own, keeping it in step
 * with contract.play.
 */
export const ExtensionNamePanel = mountComponent((host, properties, context) => {
    const document = host.ownerDocument;
    const summary = document.createElement('p');
    summary.setAttribute('data-summary', '');
    const button = document.createElement('button');
    button.type = 'button';
    button.textContent = 'Greet';
    const message = document.createElement('p');
    message.setAttribute('data-message', '');
    host.append(summary, button, message);

    let label = String(properties.label);
    const render = () => { summary.textContent = `${label}|${context.user.name}|${context.locale.language}`; };
    const greet = async () => {
        const result = (await context.invoke('Greet', { name: context.user.name })) as { message: string };
        message.textContent = result.message;
        context.raise('greeted', { message: result.message });
    };

    render();
    button.addEventListener('click', greet);
    const unsubscribe = context.subscribe(render);

    return {
        update: next => { label = String(next.label); render(); },
        unmount: () => {
            unsubscribe();
            button.removeEventListener('click', greet);
            summary.remove();
            button.remove();
            message.remove();
        }
    };
});
