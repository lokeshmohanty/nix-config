{
  inputs,
  ...
}:
{
  imports = [ inputs.ecr.homeManagerModules.default ];

  # ecr is a user interface over the notmuch maildir this directory already
  # builds: mbsync fetches into it, msmtp sends from it, and notmuch indexes it.
  # It owns none of that and would have nothing to show without it.
  programs.ecr = {
    enable = true;
    desktop = true;

    server = {
      # A systemd *user* service, because the maildir, the notmuch database and
      # the token store are all in $HOME and Xapian has to write there.
      enable = true;

      # Loopback. Reaching this from a phone means binding the tailnet address
      # instead — and issuing a token first with `ecr token new phone --qr`,
      # since the API is unauthenticated while no tokens exist.
      bind = "127.0.0.1:8383";
    };
  };
}
