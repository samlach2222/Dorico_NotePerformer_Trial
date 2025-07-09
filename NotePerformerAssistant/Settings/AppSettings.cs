using System.ComponentModel;

namespace NotePerformerAssistant.Model
{
    public class AppSettings : INotifyPropertyChanged
    {
        private string? _selectedFile;
        public string? SelectedFile
        {
            get => _selectedFile;
            set
            {
                if (_selectedFile != value)
                {
                    _selectedFile = value;
                    OnPropertyChanged(nameof(SelectedFile));
                }
            }
        }

        private string? _selectedMusicSoftware;
        public string? SelectedMusicSoftware
        {
            get => _selectedMusicSoftware;
            set
            {
                if (_selectedMusicSoftware != value)
                {
                    _selectedMusicSoftware = value;
                    OnPropertyChanged(nameof(SelectedMusicSoftware));
                }
            }
        }

        private string? _theme;
        public string? Theme
        {
            get => _theme;
            set
            {
                if (_theme != value)
                {
                    _theme = value;
                    OnPropertyChanged(nameof(Theme));
                }
            }
        }

        private bool? _configurationFinished;
        public bool? ConfigurationFinished
        {
            get => _configurationFinished;
            set
            {
                if (_configurationFinished != value)
                {
                    _configurationFinished = value;
                    OnPropertyChanged(nameof(ConfigurationFinished));
                }
            }
        }

        public event PropertyChangedEventHandler? PropertyChanged;

        protected void OnPropertyChanged(string propertyName) =>
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
    }
}