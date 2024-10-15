{ pkgs, ... }:
{
  users.users.dancho = {
    hashedPasswordFile = "/etc/nixos/hashedPassword";
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "input"
      "networkmanager"
    ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [ ];
  };
}
