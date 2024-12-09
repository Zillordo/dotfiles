let
  email = "konecnyallan@gmail.com";
  name = "Zillordo";
in {
  programs.git = {
    enable = true;
    extraConfig = {
      color.ui = true;
      core.editor = "nvim";
      credential.helper = "store";
      github.user = name;
      rerere.enable = true;
      rebase = { udpateRefs = true; };
      push = { autoSetupRemote = true; };
    };
    userEmail = email;
    userName = name;
  };
}
