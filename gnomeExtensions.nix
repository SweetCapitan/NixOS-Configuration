{lib, pkgs, ...}: {
	home.packages = with pkgs.gnomeExtensions; [
		blur-my-shell
		clipboard-history
		control-blur-effect-on-lock-screen
		dash-to-dock
		gsconnect
		hide-top-bar
		just-perfection
		panel-corners
		primary-input-on-lockscreen
		rounded-corners
		sound-output-device-chooser
		spotify-tray
		syncthing-indicator
		topicons-plus
		tray-icons-reloaded
	];
}
