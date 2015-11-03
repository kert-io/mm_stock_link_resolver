key='/Users/kertheinecke/.ssl/test.server.key'
cert='/Users/kertheinecke/.ssl/test.server.crt'
thin start -a 127.0.0.1 -p 4001 --ssl --ssl-disable-verify --ssl-key-file $key --ssl-cert-file $cert