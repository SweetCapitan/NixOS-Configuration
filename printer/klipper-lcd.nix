{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.klipper-lcd;

  klipperLCDRepo =
    let
      originalSrc = pkgs.fetchFromGitHub {
        owner = "joakimtoe";
        repo = "KlipperLCD";
        rev = "25b2f6c8295d4df9cb274a32f236e349640f6aee"; # или другой commit/tag
        sha256 = "sha256-DN2FD9buzYLxw3nxRzqvGnhc3R546eMfJPrFQX1Gg9k=";
      };

    in
    # Нормализуем все *.py файлы в LF
    #src-fixed = pkgs.runCommand "klipper-lcd-fixed" {} ''
    # cp -r ${originalSrc} $out
    # chmod -R +w $out
    # find $out -type f -name '*.py' -exec sed -i 's/\r$//' {} +
    #'';
    pkgs.applyPatches {
      name = "klipper-lcd-patched";
      src = originalSrc;
      patches = [ ./klipper_lcd_add_env.patch ];
    };

  klipperLCDPython = pkgs.python3.withPackages (
    ps: with ps; [
      pyserial
      requests
      setuptools
      pillow
    ]
  );
in
{
  options.services.klipper-lcd = {
    enable = lib.mkEnableOption "KlipperLCD service";

    user = lib.mkOption {
      type = lib.types.str;
      default = "klipper-lcd";
      description = "User to run KlipperLCD service";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "klipper-lcd";
      description = "Group to run KlipperLCD service";
    };

    device = lib.mkOption {
      type = lib.types.str;
      default = "/dev/ttyKlipperLCD"; # Изменено с /dev/ttyAMA0
      description = "Serial device for LCD communication";
    };

    klippySock = lib.mkOption {
      type = lib.types.str;
      default = "/home/pi/printer_data/comms/klippy.sock";
      description = "Path to klippy socket file";
    };

    moonrakerUrl = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Moonraker URL";
    };
  };

  config = lib.mkIf cfg.enable {
    # Create user and group
    users.users = lib.mkIf (cfg.user != "root") {
      "${cfg.user}" = {
        isSystemUser = true;
        group = cfg.group;
        description = "KlipperLCD service user";
        home = "/var/lib/klipper-lcd";
        createHome = true;
      };
    };

    users.groups = lib.mkIf (cfg.group != "root") {
      "${cfg.group}" = { };
    };

    # Systemd service
    systemd.services.klipper-lcd = {
      description = "KlipperLCD Service";
      wantedBy = [ "multi-user.target" ];
      after = [
        "network.target"
        "moonraker.service"
      ];
      requires = [ "moonraker.service" ];

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        WorkingDirectory = "${klipperLCDRepo}";
        ExecStart = "${klipperLCDPython}/bin/python ${klipperLCDRepo}/main.py";
        Restart = "always";
        RestartSec = 1;
        Environment = [
          "LCD_DEVICE=${cfg.device}"
          "KLIPPY_SOCK=${cfg.klippySock}"
          "MOONRAKER_URL=${cfg.moonrakerUrl}"
        ];
        # Log to journalctl instead of /tmp
        StandardOutput = "journal";
        StandardError = "journal";
      };

      environment = {
        PYTHONPATH = "${klipperLCDRepo}";
      };
    };

    # Required packages
    environment.systemPackages = with pkgs; [
      klipperLCDPython
      git
    ];

    # udev rules for serial device access
    services.udev.extraRules = ''
      # Создаем стабильную символьную ссылку для CH340/CH341 устройства
      SUBSYSTEM=="tty", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", SYMLINK+="ttyKlipperLCD", GROUP="${cfg.group}", MODE="0660"
      SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", GROUP="${cfg.group}", MODE="0660"
      KERNEL=="ttyAMA0", GROUP="${cfg.group}", MODE="0660"

      # Убираем правило для ttyUSB0, так как оно нестабильно
      # KERNEL=="ttyUSB0", GROUP="${cfg.group}", MODE="0660"
    '';

    # Ensure the klippy socket directory exists and has correct permissions
    system.activationScripts.klipper-lcd =
      let
        sockDir = builtins.dirOf cfg.klippySock;
      in
      {
        text = ''
          mkdir -p ${sockDir}
          chown ${cfg.user}:${cfg.group} ${sockDir}
        '';
        deps = [ ];
      };

  };
}
