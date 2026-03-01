import { BrowserRouter, Route, Routes } from 'react-router-dom';
import { DialogComponents } from '@cratis/arc.react/dialogs';
import { BusyIndicatorDialog, ConfirmationDialog } from '@cratis/components/Dialogs';
import { SomeFeature } from '../Features/SomeFeature';

function App() {
    return (
        <DialogComponents confirmation={ConfirmationDialog} busyIndicator={BusyIndicatorDialog}>
            <BrowserRouter>
                <Routes>
                    <Route path='/' element={<SomeFeature />} />
                </Routes>
            </BrowserRouter>
        </DialogComponents>
    );
}

export default App;
