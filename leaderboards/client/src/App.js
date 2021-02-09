import React from 'react';
import MainApp from './MainApp';
import CssBaseline from '@material-ui/core/CssBaseline';
import { createMuiTheme, ThemeProvider } from '@material-ui/core/styles';

function App() {
  const theme = React.useMemo(
    () =>
      createMuiTheme({
        palette: {
          type: 'dark',
        },
      })
  );
  return (
    <React.Fragment>
    <ThemeProvider theme={theme}>
      <CssBaseline />
      
        <MainApp />
      </ThemeProvider>
    </React.Fragment>
  )
}

export default App;
