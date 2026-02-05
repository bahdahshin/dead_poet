{ config, pkgs, ... }:
{
  virtualisation.docker.enable = true;
  services.open-vm-tools.enable = true;

  users.users.nixos.extraGroups = [ "docker" ];

  environment.systemPackages = with pkgs; [ docker-compose ];
}
