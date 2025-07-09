using System;
using Avalonia;
using Avalonia.Controls;
using Avalonia.Interactivity;
using Avalonia.Styling;
using NotePerformerAssistant.Model;

namespace NotePerformerAssistant
{
    public partial class Theme : UserControl
    {
        public event EventHandler<RoutedEventArgs>? NextClicked;

        public Theme()
        {
            InitializeComponent();
            InitializeThemeSelector();
            NextButton.Click += (s, e) => NextClicked?.Invoke(this, e);
        }

        private void InitializeThemeSelector()
        {
            ThemeSelector.SelectionChanged += ThemeSelector_SelectionChanged;
            applyTheme();
        }

        private void ThemeSelector_SelectionChanged(object? sender, SelectionChangedEventArgs e)
        {
            applyTheme();
        }

        private void applyTheme()
        {
            switch (ThemeSelector.SelectedIndex)
            {
                case 0:
                    Application.Current!.RequestedThemeVariant = ThemeVariant.Light;
                    SettingsManager.Current.Theme = NotePerformerAssistantModel.Light;
                    break;
                case 1:
                    Application.Current!.RequestedThemeVariant = ThemeVariant.Dark;
                    SettingsManager.Current.Theme = NotePerformerAssistantModel.Dark;
                    break;
                case 2:
                    Application.Current!.RequestedThemeVariant = ThemeVariant.Default;
                    SettingsManager.Current.Theme = NotePerformerAssistantModel.System;
                    break;
            }
            SettingsManager.Save();
        }
    }
}