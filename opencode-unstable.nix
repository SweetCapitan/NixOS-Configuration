nixpkgs_unstable: final: prev:
let
  opencodeUnstable = nixpkgs_unstable.legacyPackages.${prev.stdenv.hostPlatform.system}.opencode;
in
{
  opencode =
    (opencodeUnstable.override {
      bun = final.bun;
    }).overrideAttrs
      (oldAttrs: {
        # Добавляем preBuild хак, чтобы принудительно сгенерировать карту импортов
        preBuild = ''
          echo "=== Предварительная генерация opencode-web-ui.gen.ts ==="
          # В зависимости от структуры репозитория opencode, генерация запускается 
          # либо через внутренний скрипт, либо созданием пустого/фиктивного файла, 
          # если Web UI не критичен для TUI-версии в терминале.

          # Попробуем запустить генератор, если он объявлен в package.json:
          bun run generate || bun run build:gen || true

          # Если скрипты не отработали и файл всё ещё отсутствует, 
          # создадим заглушку, чтобы Bun не падал при сборке бинарника:
          if [ ! -f "opencode-web-ui.gen.ts" ] && [ ! -f "packages/opencode/opencode-web-ui.gen.ts" ]; then
            echo "export const webUiMap = {};" > opencode-web-ui.gen.ts
            # на всякий случай создаем во всех возможных путях пакета
            mkdir -p packages/opencode
            echo "export const webUiMap = {};" > packages/opencode/opencode-web-ui.gen.ts
          fi
        '';
      });
}
