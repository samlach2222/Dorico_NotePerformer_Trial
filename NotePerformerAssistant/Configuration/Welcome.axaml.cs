using System;
using Avalonia;
using Avalonia.Controls;
using Avalonia.Interactivity;
using Avalonia.Media;

namespace NotePerformerAssistant
{
    public partial class Welcome : UserControl
    {
        public event EventHandler<RoutedEventArgs>? NextClicked;
        
        public Welcome()
        {
            InitializeComponent();
            NextButton.Click += (s, e) => NextClicked?.Invoke(this, e);
        }
    }
}