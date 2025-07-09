using System;
using Avalonia.Controls;
using Avalonia.Interactivity;


namespace NotePerformerAssistant
{
    public partial class ActionButton : UserControl
    {
        public event EventHandler<RoutedEventArgs>? Click;

        public ActionButton()
        {
            InitializeComponent();

            InnerButton.Click += (sender, e) => Click?.Invoke(this, e);
        }
    }
}