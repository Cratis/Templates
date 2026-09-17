// Copyright (c) Cratis. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

import { BrowserRouter, Route, Routes } from 'react-router-dom';
import { DialogComponents } from '@cratis/arc.react/dialogs';
import { BusyIndicatorDialog, ConfirmationDialog } from '@cratis/components/Dialogs';
import { Home } from './Home';
import { SomeFeature } from './SomeModule/SomeFeature';

function App() {
    return (
        <DialogComponents confirmation={ConfirmationDialog} busyIndicator={BusyIndicatorDialog}>
            <BrowserRouter>
                <Routes>
                    <Route path='/' element={<Home />} />
                    <Route path='/demo' element={<SomeFeature />} />
                </Routes>
            </BrowserRouter>
        </DialogComponents>
    );
}

export default App;
