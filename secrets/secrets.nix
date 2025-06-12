# secrets/secrets.nix
let
  my_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOmxv5PDX2SdCCruCl7qjaUc+07s3tk+dy+vPY6NGBRn root@8f193fa08f6c";
in 
{
  "secret1.age".publicKeys = [my_key];
}

