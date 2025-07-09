using System;
using System.Linq;
using Avalonia.Controls;
using Avalonia.Input;
using Avalonia.Interactivity;
using Avalonia.Platform.Storage;
using Avalonia.VisualTree;
using NotePerformerAssistant.Model;

namespace NotePerformerAssistant
{
    public partial class MusicSoftware : UserControl
    {
        public event EventHandler<RoutedEventArgs>? NextClicked;

        public MusicSoftware()
        {
            InitializeComponent();
            MusicSoftwareSelector.SelectionChanged += MusicSoftwareSelector_SelectionChanged;
            ApplyMusicSoftware();
            NextButton.Click += (s, e) => NextClicked?.Invoke(this, e);
        }

        private void MusicSoftwareSelector_SelectionChanged(object? sender, SelectionChangedEventArgs e)
        {
            ApplyMusicSoftware();
        }

        private void ApplyMusicSoftware()
        {
            SettingsManager.Current.SelectedMusicSoftware = MusicSoftwareSelector.SelectedIndex switch
            {
                0 =>
                    SettingsManager.Current.SelectedMusicSoftware = NotePerformerAssistantModel.Dorico,
                1 =>
                    SettingsManager.Current.SelectedMusicSoftware = NotePerformerAssistantModel.Sibelius,
                2 =>
                    SettingsManager.Current.SelectedMusicSoftware = NotePerformerAssistantModel.Finale,
                _ => SettingsManager.Current.SelectedMusicSoftware
            };
            SettingsManager.Save();
        }

        private async void ExePathTextBox_PointerReleased(object? sender, PointerReleasedEventArgs e)
        {
            var window = this.GetVisualRoot() as Window;
            if (window?.StorageProvider is not { } provider) return;
            var files = await provider.OpenFilePickerAsync(new FilePickerOpenOptions
            {
                Title = "Choisir un fichier .exe",
                AllowMultiple = false,
                FileTypeFilter =
                [
                    new FilePickerFileType("Fichiers EXE") { Patterns = ["*.exe"] }
                ]
            });

            var selected = files.FirstOrDefault();
            if (selected == null) return;
            SettingsManager.Current.SelectedFile = selected.Path.LocalPath;
            SettingsManager.Save();
            ExePathTextBox.Text = selected.Path.LocalPath;
        }
    }
}