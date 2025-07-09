using Avalonia.Controls;
using Avalonia.Interactivity;
using Avalonia.Animation;
using System;
using System.Threading.Tasks;
using Avalonia.Media;
using Avalonia.Styling;
using NotePerformerAssistant.Resources;

namespace NotePerformerAssistant
{
    public partial class Configuration : UserControl
    {
        private readonly UserControl[] _pages;
        private int _currentPageIndex;
        private bool _isAnimating;

        public Configuration()
        {
            InitializeComponent();

            _pages = new UserControl[]
            {
                new Welcome(),
                new Theme(),
                new MusicSoftware()
            };

            foreach (var page in _pages)
            {
                var nextBtn = page.FindControl<ActionButton>("NextButton");
                if (nextBtn != null)
                    nextBtn.Click += OnNextClicked;
            }

            ContentArea.Content = _pages[_currentPageIndex];
            ContentArea.Opacity = 1;
        }

        private async Task FadeOutInAsync()
        {
            if (_isAnimating || _currentPageIndex >= _pages.Length - 1)
                return;

            _isAnimating = true;

            var fadeOut = new Animation
            {
                Duration = TimeSpan.FromMilliseconds(250),
                Children =
                {
                    new KeyFrame
                    {
                        Cue = new Cue(1),
                        Setters =
                        {
                            new Setter(OpacityProperty, 0.0)
                        }
                    }
                }
            };

            var fadeIn = new Animation
            {
                Duration = TimeSpan.FromMilliseconds(500),
                Children =
                {
                    new KeyFrame
                    {
                        Cue = new Cue(1),
                        Setters =
                        {
                            new Setter(OpacityProperty, 1.0)
                        }
                    }
                }
            };

            await fadeOut.RunAsync(ContentArea);

            _currentPageIndex++;
            if (_currentPageIndex >= _pages.Length)
                _currentPageIndex = 0;
            ContentArea.Content = _pages[_currentPageIndex];

            await fadeIn.RunAsync(ContentArea);

            _isAnimating = false;
        }

        private async void OnNextClicked(object? sender, RoutedEventArgs e)
        {
            if (_currentPageIndex >= _pages.Length - 1)
            {
                if (SettingsManager.Current.SelectedFile != null &&
                    SettingsManager.Current.SelectedMusicSoftware != null)
                {
                    SettingsManager.Current.ConfigurationFinished = true;
                    SettingsManager.Save();
                }
                else
                {
                    var currentPage = _pages[_currentPageIndex];
                    var errorHint = currentPage.FindControl<TextBlock>("ErrorHint");
                    if (errorHint != null)
                    {
                        errorHint.IsVisible = true;
                        errorHint.Foreground = Brushes.Red;
                        errorHint.Text = Strings.Configuration_SelectExe;
                    }
                }
            }
            await FadeOutInAsync();
        }
    }
}
