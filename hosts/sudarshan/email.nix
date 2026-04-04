{
  config,
  lib,
  mkCalendar,
  mkContact,
  mkEmail,
  selectAccounts,
  setPrimaryAccount,
  ...
}:
{
  modules.email.enable = true;

  accounts.contact = {
    basePath = "${config.xdg.dataHome}/contacts";
    accounts = lib.mapAttrs mkContact (selectAccounts [
      "main"
      "personal"
      "zenteiq"
    ]);
  };

  accounts.calendar = {
    basePath = "${config.xdg.dataHome}/calendars";
    accounts = lib.mapAttrs mkCalendar (selectAccounts [
      "main"
      "personal"
      "zenteiq"
    ]);
  };

  accounts.email = {
    maildirBasePath = "${config.xdg.dataHome}/Mail";
    accounts = lib.mapAttrs mkEmail (
      setPrimaryAccount "main" (selectAccounts [
        "main"
        "personal"
        "iisc"
        "zenteiq"
      ])
    );
  };
}
