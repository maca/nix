{ ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
        extraOptions = {
          UseKeychain = "yes";
          IdentityFile = "~/.ssh/id_ed25519";
        };
      };
      router = {
        hostname = "192.168.8.1";
        user = "root";
      };
      borgbase-documents = {
        hostname = "evbhn1yc.repo.borgbase.com";
        user = "evbhn1yc";
        serverAliveInterval = 60;
        serverAliveCountMax = 10;
      };
      borgbase-photos = {
        hostname = "qyi5rs0y.repo.borgbase.com";
        user = "qyi5rs0y";
        serverAliveInterval = 60;
        serverAliveCountMax = 10;
      };
    };
  };
}
