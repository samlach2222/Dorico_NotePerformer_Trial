using System.ComponentModel;
using Avalonia.Controls;
using Avalonia.Threading;
using NotePerformerAssistant.Model;

namespace NotePerformerAssistant
{
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();

            SettingsManager.Current.PropertyChanged += OnSettingsChanged;

            SetInitialContent();
        }

        private void SetInitialContent()
        {
            if (SettingsManager.Current.ConfigurationFinished != null && SettingsManager.Current.ConfigurationFinished == true)
                MainContent.Content = new Dashboard();
            else
                MainContent.Content = new Configuration();
        }

        private void OnSettingsChanged(object? sender, PropertyChangedEventArgs e)
        {
            if (e.PropertyName == nameof(AppSettings.ConfigurationFinished)
                && SettingsManager.Current.ConfigurationFinished != null &&  SettingsManager.Current.ConfigurationFinished == true)
            {
                Dispatcher.UIThread.Post(() =>
                {
                    MainContent.Content = new Dashboard();
                });
            }
        }
    }

}