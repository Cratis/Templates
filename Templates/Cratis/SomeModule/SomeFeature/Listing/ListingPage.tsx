// Copyright (c) Cratis. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

import { Column, DataPage, MenuItem } from "@cratis/components/DataPage";
import { AllListings } from "./Listing";
import { MdAdd } from "react-icons/md";

export interface ListingPageProps {
    onRegister(): void;
}

export const ListingPage = ({ onRegister }: ListingPageProps) => {
    return (
        <DataPage
            title="SomeFeature"
            query={AllListings}
            dataKey="eventSourceId"
            emptyMessage="No items registered yet."
        >
            <DataPage.MenuItems>
                <MenuItem label="Register" icon={MdAdd} command={onRegister} />
            </DataPage.MenuItems>
            <DataPage.Columns>
                <Column field="name" header="Name" />
                <Column field="eventSourceId" header="Id" />
            </DataPage.Columns>
        </DataPage>
    );
};
