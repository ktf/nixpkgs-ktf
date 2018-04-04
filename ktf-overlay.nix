self: super:

let
  myTmux = super.tmux.overrideAttrs (oldAttrs: rec {
    version = "2.6";
    src = super.fetchFromGitHub {
      owner = "tmux";
      repo = "tmux";
      rev = version;
      sha256 = "0605y0nwfmf0mnq075vk80897c2cvhxxvxinqq7hvrpjf2ph5mww";
    };
  });

  myIsync = super.isync.overrideAttrs (oldAttrs: rec {
    name = "isync-1.3.0";
    src = super.fetchurl {
      url = "mirror://sourceforge/isync/${name}.tar.gz";
      sha256 = "1bij6nm06ghkg98n2pdyacam2fyg5y8f7ajw0d5653m0r4ldw5p7";
    };
  });

  myTerraform = super.terraform.overrideAttrs (old: rec {
    name = "terraform-0.11.3";
    version = "0.11.3";
    src = super.fetchFromGitHub {
      owner  = "hashicorp";
      repo   = "terraform";
      rev    = "v${version}";
      sha256 = "0637x7jcm62pdnivmh4rggly6dmlvdh3jpsd1z4vba15gbm203nz";
    };
  });

  myGit = super.git.overrideAttrs (old: rec {
    name = "git-${version}";
    version = "2.16.2";
    src = super.fetchurl {
      url = "https://www.kernel.org/pub/software/scm/git/git-${version}.tar.xz";
      sha256 = "05y7480f2p7fkncbhf08zz56jbykcp0ia5gl6y3djs0lsa5mfq2m";
    };
  });

  myWeechat = super.callPackage ../nixpkgs/pkgs/applications/networking/irc/weechat { libobjc = super.darwin.libobjc; libresolv = super.darwin.libresolv;
  };
in
{
  ccacheWrapper = super.ccacheWrapper.override {
    extraConfig = ''
      export CCACHE_COMPRESS=1
      export CCACHE_DIR=~/.ccache
      export CCACHE_UMASK=007
    '';
  };

  ktf = (super.ktf or {}) // {
     weechat = myWeechat.override {
       guileSupport = false;
       tclSupport = false;
       configure = with super; { availablePlugins, ... }: {
         plugins = with availablePlugins; [
              (python.withPackages (ps: with ps; [ pycrypto websocket_client ]))
               perl
              ];
       };
     };
    tmux = myTmux;
    terraform = myTerraform;
    git = myGit;
  };

}
