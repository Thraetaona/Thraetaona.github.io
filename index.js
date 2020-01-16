const { createTheme, Customizations, DefaultButton, PrimaryButton, Toggle, TooltipHost } = Fabric;

const myTheme = createTheme({
  palette: {
    themePrimary: '#3c0082',
    themeLighterAlt: '#f5f0fa',
    themeLighter: '#d7c5eb',
    themeLight: '#b798da',
    themeTertiary: '#7a48b4',
    themeSecondary: '#4d1191',
    themeDarkAlt: '#370075',
    themeDark: '#2e0063',
    themeDarker: '#220049',
    neutralLighterAlt: '#f8f8f8',
    neutralLighter: '#f4f4f4',
    neutralLight: '#eaeaea',
    neutralQuaternaryAlt: '#dadada',
    neutralQuaternary: '#d0d0d0',
    neutralTertiaryAlt: '#c8c8c8',
    neutralTertiary: '#bab8b7',
    neutralSecondary: '#a3a2a0',
    neutralPrimaryAlt: '#8d8b8a',
    neutralPrimary: '#323130',
    neutralDark: '#605e5d',
    black: '#494847',
    white: '#ffffff',
  }});

class Content extends React.Component {
    public render()
    {
      Customizations.applySettings({ theme: myTheme });
      return (
        <div>
          <DefaultButton text="DefaultButton"/><PrimaryButton text="PrimaryButton"/>
          <Toggle label="Enabled"/><Toggle label="Disabled" disabled={true}/>
        </div>
      );
    }
}
ReactDOM.render(<Content />,document.getElementById('content'));
