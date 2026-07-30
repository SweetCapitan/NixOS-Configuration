{ pkgs, lib, ... }:
let
  kampSrc = pkgs.fetchFromGitHub {
    owner = "kyleisah";
    repo = "Klipper-Adaptive-Meshing-Purging";
    rev = "b0dad8ec9ee31cb644b94e39d4b8a8fb9d6c9ba0";
    sha256 = "sha256-05l1rXmjiI+wOj2vJQdMf/cwVUOyq5d21LZesSowuvc=";
  };

  kampSettings = pkgs.writeText "KAMP_Settings.cfg" ''
    [include ./KAMP/Adaptive_Meshing.cfg]
    [include ./KAMP/Line_Purge.cfg]
    [include ./KAMP/Smart_Park.cfg]

    [gcode_macro _KAMP_Settings]
    description: This macro contains all adjustable settings for KAMP

    variable_verbose_enable: True
    variable_mesh_margin: 0
    variable_fuzz_amount: 0

    # Uncomment + set if you use a dockable probe (Klicky/Euclid/etc.)
    variable_probe_dock_enable: False
    variable_attach_macro: 'Attach_Probe'
    variable_detach_macro: 'Dock_Probe'

    variable_purge_height: 0.8
    variable_tip_distance: 0
    variable_purge_margin: 10
    variable_purge_amount: 50
    variable_flow_rate: 12

    variable_smart_park_height: 10

    gcode:
        {action_respond_info(" Running the KAMP_Settings macro does nothing, it is only used for storing KAMP settings. ")}
  '';

  kampStartPrint = pkgs.writeText "KAMP_Start_Print.cfg" ''
    [gcode_macro START_PRINT]
    rename_existing: START_PRINT_BASE
    gcode:
        {% set BED_TEMP = params.BED_TEMP|default(60)|float %}
        {% set EXTRUDER_TEMP = params.EXTRUDER_TEMP|default(200)|float %}
        {% set adaptive_mesh = printer["output_pin kamp_adaptive_mesh"].value|int %}
        {% set adaptive_purge = printer["output_pin kamp_adaptive_purge"].value|int %}

        G90
        G28
        M140 S{BED_TEMP}
        M104 S150
        M190 S{BED_TEMP}

        {% if adaptive_mesh %}
            BED_MESH_CALIBRATE            ; KAMP-overridden, adaptive
        {% else %}
            _BED_MESH_CALIBRATE           ; original Klipper macro, full-bed classic
        {% endif %}

        SMART_PARK
        M109 S{EXTRUDER_TEMP}

        {% if adaptive_purge %}
            LINE_PURGE
        {% else %}
            G1 X1.5 Y20 F5000.0           ; your old classic purge line
            G1 Y120.0 F600.0 E15
            G1 X0.5 F1000.0
            G1 Y20 F600 E30
        {% endif %}

        G92 E0
  '';
in
{
  systemd.tmpfiles.rules = [
    "L+ /var/lib/moonraker/config/KAMP - - - - ${kampSrc}/Configuration"
    "C /var/lib/moonraker/config/KAMP_Settings.cfg - - - - ${kampSettings}"
    "C /var/lib/moonraker/config/KAMP_Start_Print.cfg - - - - ${kampStartPrint}"
  ];
}
