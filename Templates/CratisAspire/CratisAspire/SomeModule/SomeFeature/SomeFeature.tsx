import { RegisterDialog } from './Registration';
import { ListingPage } from './Listing';
import { useDialog } from '@cratis/arc.react/dialogs';

export const SomeFeature = () => {
    const [RegistrationDialog, showRegistrationDialog] = useDialog(RegisterDialog);

    return (
        <>
            <ListingPage onRegister={() => { void showRegistrationDialog(); }} />
            <RegistrationDialog />
        </>
    );
};
