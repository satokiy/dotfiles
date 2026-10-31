package main

import (
	"bytes"
	"fmt"
	"os"
	"path/filepath"

	"github.com/pelletier/go-toml/v2"
)

func main() {
	if err := run(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

func run() error {
	if len(os.Args) != 2 {
		return fmt.Errorf("usage: setup <config directory>")
	}
	sourceDir, err := filepath.Abs(os.Args[1])
	if err != nil {
		return err
	}
	sourceDir, err = filepath.EvalSymlinks(sourceDir)
	if err != nil {
		return err
	}
	codexHome := os.Getenv("CODEX_HOME")
	if codexHome == "" {
		home, err := os.UserHomeDir()
		if err != nil {
			return err
		}
		codexHome = filepath.Join(home, ".codex")
	}
	codexHome, err = filepath.Abs(codexHome)
	if err != nil {
		return err
	}
	if resolved, err := filepath.EvalSymlinks(codexHome); err == nil {
		codexHome = resolved
	}
	return setup(sourceDir, codexHome)
}

func setup(sourceDir, codexHome string) error {
	settingsText, err := os.ReadFile(filepath.Join(sourceDir, "config.toml"))
	if err != nil {
		return err
	}
	var settings struct {
		TUI map[string]any `toml:"tui"`
	}
	if err := toml.Unmarshal(settingsText, &settings); err != nil {
		return err
	}
	if len(settings.TUI) == 0 {
		return fmt.Errorf("config.toml に tui の設定がありません")
	}
	target := filepath.Join(codexHome, "config.toml")
	if info, err := os.Lstat(target); err == nil && info.Mode()&os.ModeSymlink != 0 {
		return fmt.Errorf("既存のシンボリックリンクを確認してください: %s", target)
	} else if err != nil && !os.IsNotExist(err) {
		return err
	}
	text, err := os.ReadFile(target)
	targetExists := err == nil
	if err != nil && !os.IsNotExist(err) {
		return err
	}
	merged, err := mergeNotifications(text, settings.TUI)
	if err != nil {
		return err
	}
	if bytes.Equal(merged, text) {
		fmt.Println("Unchanged:", target)
		return nil
	}
	if err := os.MkdirAll(codexHome, 0700); err != nil {
		return err
	}
	if targetExists {
		backup, err := os.CreateTemp(codexHome, "config.toml.backup-*")
		if err != nil {
			return err
		}
		_, writeErr := backup.Write(text)
		closeErr := backup.Close()
		if writeErr != nil {
			return writeErr
		}
		if closeErr != nil {
			return closeErr
		}
		fmt.Println("Backup:", backup.Name())
	}
	if err := atomicWrite(target, merged); err != nil {
		return err
	}
	fmt.Println("Updated:", target)
	return nil
}

// mergeNotifications updates TUI settings and serializes the entire config.
func mergeNotifications(text []byte, settings map[string]any) ([]byte, error) {
	var original map[string]any
	if err := toml.Unmarshal(text, &original); err != nil {
		return nil, err
	}
	if original == nil {
		original = make(map[string]any)
	}
	tui, ok := original["tui"].(map[string]any)
	if !ok && original["tui"] != nil {
		return nil, fmt.Errorf("tui must be a table")
	}
	if tui == nil {
		tui = make(map[string]any)
	}
	for key, value := range settings {
		tui[key] = value
	}
	original["tui"] = tui
	return toml.Marshal(original)
}

// atomicWrite uses a private temporary file and replaces the destination only
// after writing and closing succeeds. CreateTemp gives the file mode 0600.
func atomicWrite(path string, data []byte) error {
	f, err := os.CreateTemp(filepath.Dir(path), ".config-*")
	if err != nil {
		return err
	}
	defer os.Remove(f.Name())
	_, writeErr := f.Write(data)
	closeErr := f.Close()
	if writeErr != nil {
		return writeErr
	}
	if closeErr != nil {
		return closeErr
	}
	return os.Rename(f.Name(), path)
}
