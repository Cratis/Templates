import cratis from '@cratis/eslint-config';
import arc from '@cratis/eslint-plugin-arc';
import components from '@cratis/eslint-plugin-components';

export default [
    // Global ignore (a config object holding only `ignores`): generated AI tooling is not application source.
    { ignores: ['.cratis/**'] },
    ...cratis.configs.consumer,
    ...arc.configs.recommended,
    ...components.configs.recommended,
];
