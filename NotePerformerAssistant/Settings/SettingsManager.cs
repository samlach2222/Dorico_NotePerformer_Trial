using System;
using System.IO;
using System.Text.Json;
using NotePerformerAssistant.Model;

public static class SettingsManager
{
    private static readonly string ConfigPath = Path.Combine(
        Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData),
        "NotePerformerAssistant",
        "settings.json");

    public static AppSettings Current { get; private set; } = Load();

    public static void Save()
    {
        var dir = Path.GetDirectoryName(ConfigPath);
        if (!Directory.Exists(dir))
            Directory.CreateDirectory(dir!);

        var json = JsonSerializer.Serialize(Current, new JsonSerializerOptions { WriteIndented = true });
        File.WriteAllText(ConfigPath, json);
    }

    private static AppSettings Load()
    {
        if (!File.Exists(ConfigPath)) return new AppSettings();
        var json = File.ReadAllText(ConfigPath);
        return JsonSerializer.Deserialize<AppSettings>(json) ?? new AppSettings();

    }
}
