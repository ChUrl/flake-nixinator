{
  # The ente containers keep their own images; only the database moves to the
  # shared PostgreSQL instance.
  services.postgresql = {
    # Containers cannot use the unix socket, so listen on TCP. The firewall
    # below only allows it from the docker bridges.
    enableTCPIP = true;

    ensureDatabases = ["ente"];

    ensureUsers = [
      {
        name = "ente";
        ensureDBOwnership = true;
        ensureClauses = {
          login = true;
          # SCRAM-SHA-256 verifier for sops `ente-db-password`
          password = "SCRAM-SHA-256$4096:bQ6Bqk1edhyUkB0zor9wZQ==$f5pCeniygqj99yXVeiGpx5a54+5aEcpxu17XsabXTEg=:pWJZ/f2KilrtLsEcDT8UJZ5z52v5QbfuNYGu+awbCrk=";
        };
      }
    ];

    authentication = ''
      host all ente 172.16.0.0/12 scram-sha-256
    '';
  };

  networking.firewall.extraInputRules = ''
    iifname "br-*" tcp dport 5432 accept
  '';
}
