import { Button } from 'primereact/button';
import { Registration } from './Registration/Registration';
import { ListingDataTable } from './Listing/ListingDataTable';
import { useDialog } from '@cratis/arc.react/dialogs';

export const SomeFeature = () => {
    const [RegistrationDialog, showRegistrationDialog] = useDialog(Registration);

    return (
        <div className='p-4'>
            <div className='flex justify-between items-center mb-4'>
                <h1 className='text-2xl font-bold'>SomeFeature</h1>
                <Button
                    label='Register'
                    icon='pi pi-plus'
                    onClick={() => showRegistrationDialog()} />
            </div>
            <ListingDataTable />
            <RegistrationDialog />
        </div>
    );
};
