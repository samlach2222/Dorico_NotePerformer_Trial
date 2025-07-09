
using Avalonia.Markup.Xaml;
using System;
using System.Resources;
using System.Threading;

namespace NotePerformerAssistant.Localization
{
    public class LocExtension : MarkupExtension
    {
        public string Key { get; set; }

        private static readonly ResourceManager _resManager =
            new ResourceManager("NotePerformerAssistant.Resources.Strings", typeof(LocExtension).Assembly);

        public LocExtension() { }

        public LocExtension(string key)
        {
            Key = key;
        }

        public override object ProvideValue(IServiceProvider serviceProvider)
        {
            if (string.IsNullOrWhiteSpace(Key))
                return string.Empty;

            try
            {
                return _resManager.GetString(Key, Thread.CurrentThread.CurrentUICulture) ?? $"!{Key}!";
            }
            catch
            {
                return $"!{Key}!";
            }
        }
    }
}