{ config, pkgs, ... }:

{
  # The state version is required and should stay at the version you originally installed.
  home.stateVersion = "26.05";

  programs.plasma = {
    enable = true;

    powerdevil.AC = {
      powerButtonAction = "sleep";
      autoSuspend = {
        action = "sleep";
        idleTimeout = 600;
      };
      whenSleepingEnter = "standbyThenHibernate";
      turnOffDisplay.idleTimeout = "never";
      dimDisplay.enable = false;
    };

    kscreenlocker = {
      autoLock = false;
      lockOnResume = false;
      timeout = 0;
      passwordRequired = false;
    };
  };
}