import 'reflect-metadata';
import { CratisComponentsProvider } from '@cratis/components/Common';
import ReactDOM from 'react-dom/client';
import 'primeicons/primeicons.css';
import './index.css';
import React from 'react';
import { Arc } from '@cratis/arc.react';
import App from '../App.tsx';

ReactDOM.createRoot(document.getElementById('root')!).render(
    <React.StrictMode>
        <CratisComponentsProvider value={{ ripple: true }}>
            <Arc>
                <App />
            </Arc>
        </CratisComponentsProvider>
    </React.StrictMode>
);
