Вот шпаргалка:

---

## DMS Matugen — кастомные шаблоны

### Два способа добавить шаблон

**1. Через `~/.config/matugen/config.toml`** (управляется `RunUserTemplates`, может быть выключено)
```toml
[config]

[templates.myapp]
input_path = '/home/user/.config/matugen/templates/myapp.conf'
output_path = '/home/user/.config/myapp/colors.conf'
```

**2. Через `~/.config/matugen/dms/configs/*.toml`** (работает **всегда**, рекомендуется)
```toml
[templates.myapp]
input_path = 'CONFIG_DIR/matugen/dms/templates/myapp.conf'
output_path = 'CONFIG_DIR/myapp/colors.conf'
```

---

### Плейсхолдеры путей
| Плейсхолдер | Раскрывается в |
|---|---|
| `CONFIG_DIR` | `~/.config` |
| `SHELL_DIR` | путь DMS в nix store |
| `HOME` | `~` |

---

### Переменные в шаблонах
```
{{colors.on_surface.default.hex}}        # цвет с #
{{colors.on_surface.default.hex_stripped}} # цвет без #

{{dank16.color0.default.hex}}  # terminal palette
```

**Варианты:**
| Вариант | Поведение |
|---|---|
| `.default` | авто dark/light (для терминалов — см. ниже) |
| `.dark` | всегда тёмный |
| `.light` | всегда светлый |

> ⚠️ Для терминальных шаблонов (`ghostty`, `kitty`, `foot` и др.) DMS автоматически заменяет `.default` → `.dark` если включена настройка **"Terminals - Always use Dark Theme"**. Используй `.light` явно для светлой темы.

---

### NixOS: добавить шаблоны через overlay

```nix
# flake.nix — overlay
dms-shell-custom = inputs.dank-material-shell.packages.${prev.system}.dms-shell.overrideAttrs (old: {
  postInstall = old.postInstall + ''
    cp ${./matugen/configs/myapp.toml} \
      $out/share/quickshell/dms/matugen/configs/myapp.toml
    cp ${./matugen/templates/myapp.conf} \
      $out/share/quickshell/dms/matugen/templates/myapp.conf
  '';
});
```

Шаблоны из `SHELL_DIR` — используй в `input_path`:
```toml
input_path = 'SHELL_DIR/matugen/templates/myapp.conf'
output_path = 'CONFIG_DIR/myapp/colors.conf'
```

Шаблоны из `CONFIG_DIR` — через `xdg.configFile` в `home.nix`, overlay не нужен:
```nix
xdg.configFile."matugen/dms/configs/myapp.toml".text = ''
  [templates.myapp]
  input_path = 'CONFIG_DIR/matugen/dms/templates/myapp.conf'
  output_path = 'CONFIG_DIR/myapp/colors.conf'
'';

xdg.configFile."matugen/dms/templates/myapp.conf".text = ''
  background = {{colors.background.default.hex}}
  foreground = {{colors.on_surface.default.hex}}
'';
```

---

### Ghostty: две темы (dark + light)
```
# ~/.config/ghostty/config
theme = light:dankcolors-light,dark:dankcolors
```
Ghostty переключается сам при смене системной темы.
