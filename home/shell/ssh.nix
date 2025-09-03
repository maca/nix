{ ... }:
{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      router = {
        hostname = "192.168.8.1";
        user = "root";
      };
      borgbase-documents = {
        hostname = "evbhn1yc.repo.borgbase.com";
        user = "evbhn1yc";
      };
      borgbase-photos = {
        hostname = "qyi5rs0y.repo.borgbase.com";
        user = "qyi5rs0y";
      };
    };
  };
}
