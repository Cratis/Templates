import { useState } from 'react';
import { Button } from 'primereact/button';

import { Registration } from './Registration/Registration';
import { ListingDataTable } from './Listing/ListingDataTable';

export const SomeFeature = () => {
    const [showRegister, setShowRegister] = useState(false);

    return (
        <div className='p-4'>
            <div className='flex justify-between items-center mb-4'>
                <h1 className='text-2xl font-bold'>SomeFeature</h1>
                <Button
                    label='Register'
                    icon='pi pi-plus'
                    onClick={() => setShowRegister(true)} />
            </div>
            <ListingDataTable/>
            <Registration showRegister={showRegister} setShowRegister={setShowRegister} />
        </div>
    );
};
