{ ... }:
{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      router = {
        hostname = "192.168.8.1";
        user = "root";
      };
    };
  };
}
