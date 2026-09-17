// Copyright (c) Cratis. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

import { CommandDialog } from '@cratis/components/CommandDialog';
import { InputTextField } from '@cratis/components/CommandForm';
import { MdEdit } from 'react-icons/md';
import { Register } from 'Api/Register';

export const RegisterDialog = () => {
    return (
        <CommandDialog
            command={Register}
            initialValues={{ id: crypto.randomUUID() }}
            title='Register'
            okLabel='Register'
            cancelLabel='Cancel'>
            <InputTextField<Register>
                value={c => c.name}
                title='Name'
                icon={<MdEdit />} />
        </CommandDialog>
    );
};
