self: super:

# This is an overlay for stuff I am staging, i.e. which are not yet in the
# official nixpkgs distribution. This way I can keep the other nixpkgs-ktf
# clean of not-yet-committed developments.
let
  something = "foo";
  newPython = import ../nixpkgs/pkgs/top-level/python-packages.nix;
in
{
  ccacheWrapper = super.ccacheWrapper.override {
    extraConfig = ''
      export CCACHE_COMPRESS=1
      export CCACHE_DIR=~/.ccache
      export CCACHE_UMASK=007
    '';
  };

  lib = super.stdenv.lib // { maintainers = import ../nixpkgs/maintainers/maintainer-list.nix; };
  buildPythonPackage = newPython.buildPythonPackage;

  ktf = (super.ktf or {}) // {
    staging = {
      uproot = import ../../propose-uproot/pkgs/development/python-modules/uproot {
        inherit (self) lib;
        inherit (super.python27.pkgs) fetchPypi;
        inherit (self) buildPythonPackage;
        inherit (super.python27.pkgs) numpy;
      };
    };
  };
}
