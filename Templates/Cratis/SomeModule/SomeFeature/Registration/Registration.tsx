import { CommandDialog } from '@cratis/components/CommandDialog';
import { InputTextField } from '@cratis/components/CommandForm';
import { Register } from './Register';

export const Registration = ({ showRegister, setShowRegister }: { showRegister: boolean; setShowRegister: (value: boolean) => void }) => {
    return (
        <>
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
        </>
    );
}