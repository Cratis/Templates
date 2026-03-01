import 'reflect-metadata';
import { PrimeReactProvider } from 'primereact/api';
import ReactDOM from 'react-dom/client';
import 'primeicons/primeicons.css';
import './index.css';
import React from 'react';
import App from './App.tsx';
import { configure as configureMobx } from 'mobx';
import { Bindings } from './Bindings';

Bindings.initialize();

configureMobx({
    enforceActions: 'never'
});

ReactDOM.createRoot(document.getElementById('root')!).render(
    <React.StrictMode>
        <PrimeReactProvider value={{ ripple: true }}>
            <App />
        </PrimeReactProvider>
    </React.StrictMode>
);
