{ pkgs, lib }:

with lib;
with builtins;


rec {
  build = { source }: let
    # the build uses emacs to perform the conversion
    env = { buildInputs = [ pkgs.emacs ]; };
    # call make-init-el to convert the file
    script = ''
      ln -s "${source}" ./init.org;
      emacs -Q --script "${./org-build.el}" -f make-init-el;
      cp ./init.el $out;
    '';
  in pkgs.runCommand "org-build" env script;

  module = {config, pkgs, lib, ...}:
  let
    cfg = config.plugins.org-build;
  in {
    options.plugins.org-build = {
      enable = mkEnableOption "Build init.el from Orgmode file";
      source = mkOption {
        type = types.path;
        description = ''
          The source orgfile to build as init.el
        '';
      };
    };

    config = mkIf cfg.enable {
      home.file.".emacs.d/init.el".source = build { source=cfg.source; };
    };
  };
}
