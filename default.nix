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
  lakeHash = "sha256-4vNbdnhsyJehfbXPQdpyADJyPMrPbhjGW9LS7YK1Q3A=";

  doCheck = true;
  checkPhase = ''
    lake test
  '';
}
