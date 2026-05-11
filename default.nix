{
  leanPackages,
}:
let
  lakefile = builtins.fromTOML (builtins.readFile ./lakefile.toml);
in
leanPackages.buildLakePackage {
  pname = lakefile.name;
  inherit (lakefile) version;
  src = builtins.path { path = ./.; };
  lakeHash = "sha256-i3On3b57tKQ4dxA9bjaRy/iNB48euhTib0594V/Egxs=";

  doCheck = true;
  checkPhase = ''
    lake test
  '';
}
