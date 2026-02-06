{ config, pkgs, ... }:
{
  virtualisation.docker.enable = true;
  users.users.nixos.extraGroups = [ "docker" ];

  environment.systemPackages = with pkgs; [ docker-compose ];
}
