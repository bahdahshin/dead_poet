{ config, pkgs, ... }:
{
  virtualisation.docker.enable = true;

  users.users.<your-username>.extraGroups = [ "docker" ];

  environment.systemPackages = with pkgs; [ docker-compose ];
}
