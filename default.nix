{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.programs.orgBuild;
  env = { buildInputs = [ pkgs.emacs ]; };
  script = ''
    ln -s "${cfg.source}" ./init.org;
    emacs -Q --script "${./org-build.el}" -f make-init-el;
    cp ./init.el $out;
  '';
  result = pkgs.runCommand "buildOrg" env script;

in {

  options.programs.orgBuild = {
    enable = mkEnableOption "Tangled Orgfile Configuration";
    source = mkOption {
      type = types.path;
      description = ''
      The source orgfile to build as init.el
      '';
    };
  };

  config = mkIf cfg.enable {
    home.file.".emacs.d/init.el".source = result.outPath;
  };
}
