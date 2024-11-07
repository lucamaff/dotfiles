{ config, ... }:

let
  immichRoot = "/mnt/data/immich"; # TODO: Tweak these to your desired storage locations
  immichPhotos = "${immichRoot}/photos";
  immichAppdataRoot = "${immichRoot}/appdata";
  immichVersion = "release";
  immichExternalVolume1 = "/mnt/data/history/BigLens/Pictures"; # TODO: if external volumes are desired

  postgresRoot = "${immichAppdataRoot}/pgsql";
  postgresPassword = "mshfyep#mnv8em"; # TODO: put a random password here
  postgresUser = "immich";
  postgresDb = "immich";

in {
  # The primary source for this configuration is the recommended docker-compose installation of immich from
  # https://immich.app/docs/install/docker-compose, which linkes to:
  # - https://github.com/immich-app/immich/releases/latest/download/docker-compose.yml
  # - https://github.com/immich-app/immich/releases/latest/download/example.env
  # and has been transposed into nixos configuration here.  Those upstream files should probably be checked
  # for serious changes if there are any upgrade problems here.
  #
  # After initial deployment, these in-process configurations need to be done:
  # - create an admin user by accessing the site
  # - login with the admin user
  # - set the "Machine Learning Settings" > "URL" to http://immich_machine_learning:3003

  # create folders needed by containers
  systemd.tmpfiles.rules = [
    "d ${immichRoot}/photos 0770 luca users -"
    "d ${immichRoot}/appdata 0770 luca users -"
    "d ${immichRoot}/appdata/pgsql 0770 luca users -"
    "d ${immichRoot}/appdata/model-cache 0770 luca users -"
  ];

  # https://github.com/NixOS/nixpkgs/issues/226365
  virtualisation.podman.defaultNetwork.settings.dns_enabled = true;

  virtualisation.oci-containers.containers.immich_server = {
    image = "ghcr.io/immich-app/immich-server:${immichVersion}";
    ports = ["2283:2283"];
    extraOptions = [
      "--pull=newer"
      # Force DNS resolution to only be the podman dnsname name server; by default podman provides a resolv.conf
      # that includes both this server and the upstream system server, causing resolutions of other pod names
      # to be inconsistent.
      "--dns=10.88.0.1"
    ];
    environment = {
      IMMICH_VERSION = immichVersion;
      DB_HOSTNAME = "immich_postgres";
      DB_USERNAME = postgresUser;
      DB_DATABASE_NAME = postgresDb;
      DB_PASSWORD = postgresPassword;
      REDIS_HOSTNAME = "immich_redis";
    };
    volumes = [
      "${immichPhotos}:/usr/src/app/upload"
      "/etc/localtime:/etc/localtime:ro"
      "${immichExternalVolume1}:${immichExternalVolume1}:ro"
    ];
  };

  virtualisation.oci-containers.containers.immich_machine_learning = {
    image = "ghcr.io/immich-app/immich-machine-learning:${immichVersion}";
    extraOptions = ["--pull=newer"];
    environment = {
      IMMICH_VERSION = immichVersion;
    };
    volumes = [
      "${immichAppdataRoot}/model-cache:/cache"
    ];
  };

  virtualisation.oci-containers.containers.immich_redis = {
    image = "redis:6.2-alpine";
  };

  virtualisation.oci-containers.containers.immich_postgres = {
    image = "tensorchord/pgvecto-rs:pg14-v0.2.1";
    environment = {
      POSTGRES_PASSWORD = postgresPassword;
      POSTGRES_USER = postgresUser;
      POSTGRES_DB = postgresDb;
    };
    volumes = [
      "${postgresRoot}:/var/lib/postgresql/data"
    ];
  };
}
