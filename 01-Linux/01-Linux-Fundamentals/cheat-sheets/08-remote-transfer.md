# Remote Connection & File Transfer

| Command | Description                              | Example Usage                        | Notes                       |
| ------- | ---------------------------------------- | ------------------------------------ | --------------------------- |
| ssh     | Secure remote shell connection           | ssh user@server_ip                   |                             |
| scp     | Securely copies files between hosts      | scp local.txt user@server:/tmp/      | Uses SSH protocol           |
| rsync   | Efficiently transfers/synchronizes files | rsync -avz local/ user@remote:/data/ |                             |
| curl    | Transfers data to/from server            | curl -O http://example.com/file.zip  | Supports multiple protocols |
