{
  lib
  , pkgs
  , stdenv
  , buildPerlPackage
  , fetchFromGitHub
}: let
  oathPerlKit = buildPerlPackage rec {
    pname = "oathPerlKit";
    version = "1.5";

    src = fetchFromGitHub {
      owner = "baierjan";
      repo = "Pass-OTP-perl";
      rev = "v${version}";
      sha256 = "sha256-crhC13RZeK2m0dJwkMbWbu/C5aL2Upcq0t8zRiMv4ZY=";
    };

    buildInputs = with pkgs; [
      oathToolkit
      perl534Packages.ConvertBase32
      perl534Packages.DigestHMAC
    ];
  };
in stdenv.mkDerivation rec {
  pname = "pass-otp";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "tadfisher";
    repo = "pass-otp";
    rev = "869828656788bd3d6f0b2fea02760d8489f4f7c1";
    sha256 = "sha256-t153Vt8vdApwi+C8bpwic6j0bU3VicjHALaUxysjq/M=";
  };

  buildInputs = [ oathPerlKit ];

  dontBuild = true;

  patchPhase = ''
    sed -i -e 's|OATH=\$(which oathtool)|OATH=${oathPerlKit}/bin/oathtool|' otp.bash
    sed -i -e 's|OTPTOOL=\$(which otptool)|OATH=${oathPerlKit}/bin/otptool|' otp.bash
  '';

  installFlags = [ "PREFIX=$(out)"
                   "BASHCOMPDIR=$(out)/share/bash-completion/completions"
                 ];

  meta = with lib; {
    description = "A pass extension for managing one-time-password (OTP) tokens";
    homepage = "https://github.com/tadfisher/pass-otp";
    license = licenses.gpl3;
    maintainers = with maintainers; [ jwiegley tadfisher toonn ];
    platforms = platforms.unix;
  };
}
