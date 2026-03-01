import { useState } from 'react';
import { Column } from 'primereact/column';
import { Button } from 'primereact/button';
import { DataTableForObservableQuery } from '@cratis/components/DataTables';
import { CommandDialog } from '@cratis/components/CommandDialog';
import { InputTextField } from '@cratis/components/CommandForm';
import { AllListings } from 'Api/SomeFeature/Listing/AllListings';
import { Register } from 'Api/SomeFeature/Registration/Register';

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
            <DataTableForObservableQuery
                query={AllListings}
                dataKey='eventSourceId'
                emptyMessage='No items registered yet.'>
                <Column field='name' header='Name' />
                <Column field='eventSourceId' header='Id' />
            </DataTableForObservableQuery>
            <CommandDialog
                command={Register}
                visible={showRegister}
                header='Register'
                confirmLabel='Register'
                cancelLabel='Cancel'
                onConfirm={result => { if (result.isSuccess) setShowRegister(false); }}
                onCancel={() => setShowRegister(false)}>
                <InputTextField<Register>
                    value={c => c.name}
                    title='Name'
                    icon={<i className='pi pi-pencil' />} />
            </CommandDialog>
        </div>
    );
};
