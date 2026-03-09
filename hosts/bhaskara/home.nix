{ config, inputs, ... }:
{
  imports = [ ../../home ];

  nixpkgs.config.permittedInsecurePackages = [
    "openclaw-2026.2.26"
  ];

  programs.openclaw = {
    documents = ./documents;

    config = {
      gateway = {
        mode = "local";
        auth.token = "0ed6259d5d2193eca7e7e482ab5c94a4";
      };
      channels.telegram = {
        tokenFile = "/home/lokesh/.secrets/telegram-token";
        allowFrom = [ 1161711558 ];
        groups."*".requireMention = true;
      };
      models.providers = {
        vllm = {
          api = "openai-responses";
          baseUrl = "http://catanzaro:8800/v1";
          apiKey = "sk-unused";
        };
      };
    };
    instances.default = {
      enable = true;
    };
  };

  programs.rclone = {
    enable = true;
# remotes = {
#   "archimedes" = {
#     config = {
#       type = "sftp";
#       host = "10.24.36.22";
#       user = "lokesh";
#       key_file = "${config.home.homeDirectory}/.ssh/id_ed25519";
#     };
#     mounts."projects" = {
#       enable = true;
#       mountPoint = "${config.home.homeDirectory}/Remotes/archimedes";
#     };
#   };
# };
  };
}
