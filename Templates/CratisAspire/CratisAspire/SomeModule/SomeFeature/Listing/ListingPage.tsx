import { DataPage, MenuItem } from '@cratis/components/DataPage';
import { AllListings } from './AllListings';
import { Column } from 'primereact/column';
import { MdAdd } from 'react-icons/md';

export interface ListingPageProps {
    onRegister(): void;
}

export const ListingPage = ({ onRegister }: ListingPageProps) => {
    return (
        <DataPage
            title='SomeFeature'
            query={AllListings}
            dataKey='eventSourceId'
            emptyMessage='No items registered yet.'>
            <DataPage.MenuItems>
                <MenuItem
                    label='Register'
                    icon={MdAdd}
                    command={onRegister} />
            </DataPage.MenuItems>
            <DataPage.Columns>
                <Column field='name' header='Name' />
                <Column field='eventSourceId' header='Id' />
            </DataPage.Columns>
        </DataPage>
    );
};
