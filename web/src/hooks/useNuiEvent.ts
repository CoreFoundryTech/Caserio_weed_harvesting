import { useEffect, useRef } from 'react';

interface NuiMessageData<T = any> {
    action: string;
    data: T;
}

export const useNuiEvent = <T = any>(action: string, handler: (data: T) => void) => {
    const savedHandler = useRef(handler);

    // Update ref.current value if handler changes.
    useEffect(() => {
        savedHandler.current = handler;
    }, [handler]);

    useEffect(() => {
        const eventListener = (event: MessageEvent<NuiMessageData<T>>) => {
            const { action: eventAction, data } = event.data;

            if (savedHandler.current && eventAction === action) {
                savedHandler.current(data);
            }
        };

        window.addEventListener('message', eventListener);
        return () => window.removeEventListener('message', eventListener);
    }, [action]);
};
