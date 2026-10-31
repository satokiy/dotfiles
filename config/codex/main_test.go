package main

import (
	"bytes"
	"os"
	"path/filepath"
	"reflect"
	"testing"

	"github.com/pelletier/go-toml/v2"
)

func notificationSettings(t *testing.T) map[string]any {
	t.Helper()
	data, err := os.ReadFile("config.toml")
	if err != nil {
		t.Fatal(err)
	}
	var settings struct {
		TUI map[string]any `toml:"tui"`
	}
	if err := toml.Unmarshal(data, &settings); err != nil {
		t.Fatal(err)
	}
	return settings.TUI
}

func TestMergePreservesSettings(t *testing.T) {
	for _, text := range []string{
		"", "model = 'example'\n", "[tui]",
		"# comment\nnotify = ['existing', 'handler']\n[tui] # keep header\nnotifications = false\nstatus_line = ['model']\n[tui.other]\nvalue = 1\n",
		"[tui]\nnotifications = [\n 'old-event',\n]\nnotification_method = 'bel'\nstatus_line = ['model']\n",
		"tui.notifications = false\ntui.status_line = ['model']\n",
	} {
		settings := notificationSettings(t)
		merged, err := mergeNotifications([]byte(text), settings)
		if err != nil {
			t.Fatal(err)
		}
		var expected, actual map[string]any
		if err := toml.Unmarshal([]byte(text), &expected); err != nil {
			t.Fatal(err)
		}
		if expected == nil {
			expected = map[string]any{}
		}
		tui, _ := expected["tui"].(map[string]any)
		if tui == nil {
			tui = map[string]any{}
		}
		for k, v := range settings {
			tui[k] = v
		}
		expected["tui"] = tui
		if err := toml.Unmarshal(merged, &actual); err != nil {
			t.Fatal(err)
		}
		if !reflect.DeepEqual(actual, expected) {
			t.Fatal("unrelated settings changed")
		}
		again, err := mergeNotifications(merged, settings)
		if err != nil || !bytes.Equal(merged, again) {
			t.Fatalf("not idempotent: %v", err)
		}
	}
	if _, err := mergeNotifications([]byte("invalid = ["), notificationSettings(t)); err == nil {
		t.Fatal("invalid TOML accepted")
	}
	if _, err := mergeNotifications([]byte("tui = false"), notificationSettings(t)); err == nil {
		t.Fatal("non-table tui accepted")
	}
}

func TestSetupBackupAndRepeat(t *testing.T) {
	root, err := filepath.EvalSymlinks(t.TempDir())
	if err != nil {
		t.Fatal(err)
	}
	source, home := filepath.Join(root, "source"), filepath.Join(root, "codex")
	for _, dir := range []string{source, home} {
		if err := os.Mkdir(dir, 0700); err != nil {
			t.Fatal(err)
		}
	}
	settings, err := os.ReadFile("config.toml")
	if err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(filepath.Join(source, "config.toml"), settings, 0600); err != nil {
		t.Fatal(err)
	}
	target := filepath.Join(home, "config.toml")
	original := []byte("model = 'example'\nnotify = ['existing', 'handler']\n[tui]\nstatus_line = ['model']\n")
	if err := os.WriteFile(target, original, 0600); err != nil {
		t.Fatal(err)
	}
	for range 2 {
		if err := setup(source, home); err != nil {
			t.Fatal(err)
		}
	}
	info, err := os.Lstat(target)
	if err != nil || !info.Mode().IsRegular() || info.Mode().Perm() != 0600 {
		t.Fatal("target must be a private regular file")
	}
	entries, err := os.ReadDir(source)
	if err != nil || len(entries) != 1 || entries[0].Name() != "config.toml" {
		t.Fatal("setup wrote machine settings into source directory")
	}
	backups, err := filepath.Glob(filepath.Join(home, "config.toml.backup-*"))
	if err != nil || len(backups) != 1 {
		t.Fatalf("wrong backups: %v %v", backups, err)
	}
	backup, err := os.ReadFile(backups[0])
	if err != nil || !bytes.Equal(backup, original) {
		t.Fatal("backup mismatch")
	}
	// An unrelated link must never be replaced.
	if err := os.Remove(target); err != nil {
		t.Fatal(err)
	}
	if err := os.Symlink(backups[0], target); err != nil {
		t.Fatal(err)
	}
	if err := setup(source, home); err == nil {
		t.Fatal("unrelated link accepted")
	}
	link, err := os.Readlink(target)
	if err != nil || link != backups[0] {
		t.Fatal("unrelated link changed")
	}
}

func TestSetupNewConfig(t *testing.T) {
	root := t.TempDir()
	source := filepath.Join(root, "source")
	home := filepath.Join(root, "codex")
	if err := os.Mkdir(source, 0700); err != nil {
		t.Fatal(err)
	}
	settings, err := os.ReadFile("config.toml")
	if err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(filepath.Join(source, "config.toml"), settings, 0600); err != nil {
		t.Fatal(err)
	}
	if err := setup(source, home); err != nil {
		t.Fatal(err)
	}
	text, err := os.ReadFile(filepath.Join(home, "config.toml"))
	if err != nil {
		t.Fatal(err)
	}
	var config map[string]any
	if err := toml.Unmarshal(text, &config); err != nil {
		t.Fatal(err)
	}
	if !reflect.DeepEqual(config["tui"], notificationSettings(t)) {
		t.Fatal("notification settings differ")
	}
}
