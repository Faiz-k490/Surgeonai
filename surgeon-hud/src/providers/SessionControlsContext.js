import { createContext, useContext } from 'react';

export const SessionControlsContext = createContext(null);

export function useSessionControls() {
  const controls = useContext(SessionControlsContext);
  if (!controls) {
    throw new Error('useSessionControls must be used inside SocketManager');
  }
  return controls;
}
