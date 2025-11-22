# File Archiving & Compression

| Command   | Description                                 | Example Usage                   | Notes                       |
| --------- | ------------------------------------------- | ------------------------------- | --------------------------- |
| tar -cvf  | Creates an archive file (.tar)              | tar -cvf archive.tar /home/data | -c: create; -f: filename    |
| tar -xvf  | Extracts files from a .tar archive          | tar -xvf archive.tar            | -x: extract                 |
| tar -czvf | Creates a compressed gzip archive (.tar.gz) | tar -czvf data.tgz /data        | -z invokes gzip compression |
