#!/usr/bin/env bash
set -euo pipefail

config_file="${1:-/etc/nixos/configuration.nix}"
module_path="./docker-compose.nix"

if [[ ! -f "$config_file" ]]; then
  echo "Error: $config_file not found." >&2
  exit 1
fi

if grep -Eq "^[[:space:]]*${module_path}[[:space:]]*$" "$config_file"; then
  echo "${module_path} is already imported in ${config_file}."
  exit 0
fi

backup_file="${config_file}.bak.$(date +%s)"
cp "$config_file" "$backup_file"

if grep -Eq "imports[[:space:]]*=[[:space:]]*\\[" "$config_file"; then
  awk -v module_line="$module_path" '
    added == 0 && $0 ~ /imports[[:space:]]*=[[:space:]]*\[/ {
      print
      print "    " module_line
      added = 1
      next
    }
    { print }
  ' "$config_file" > "${config_file}.tmp"
else
  cat "$config_file" > "${config_file}.tmp"
  cat <<EOF >> "${config_file}.tmp"

{
  imports = [
    ${module_path}
  ];
}
EOF
fi

mv "${config_file}.tmp" "$config_file"
echo "Updated ${config_file}. Backup saved to ${backup_file}."
