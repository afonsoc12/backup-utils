# Backup-utils

[![Docker Pulls](https://img.shields.io/docker/pulls/afonsoc12/backup-utils?logo=docker)](https://hub.docker.com/repository/docker/afonsoc12/backup-utils)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

[![Github Starts](https://img.shields.io/github/stars/afonsoc12/backup-utils?logo=github)](https://github.com/afonsoc12/backup-utils)
[![Github Fork](https://img.shields.io/github/forks/afonsoc12/backup-utils?logo=github)](https://github.com/afonsoc12/backup-utils)

[Backup-utils](https://hub.docker.com/afonsoc12/backup-utils) is your swiss-army knife for backups. It is a single, lightweight docker container that packages several backup and file sync tools as well as troubleshooting utilities, such as:

- [rsync](https://rsync.samba.org/): a utility that provides fast incremental file transfer.
- [rclone](https://rclone.org/): a program to manage files on cloud storage.
- [restic](https://restic.net/): a secure, lightweight and effective backup program with snapshots and deduplication built-in.
- [iperf3](https://iperf.fr/): to assess, monitor and troubleshoot the performance of your network.
- [openssh client](https://www.openssh.com/): to perform sftp-based backups.
- [fuse](https://www.kernel.org/doc/html/latest/filesystems/fuse.html): to allow mounting rclone and restic mounts.

This image is based on the lightweight [alpine](https://hub.docker.com/_/alpine) image and is built for `linux/amd64`, `linux/arm64` and `linux/arm/v7` architectures.

## Instalation

It can be pulled from both [DockerHub](https://hub.docker.com/r/afonsoc12/backup-utils) and [ghcr.io](https://github.com/afonsoc12/backup-utils/pkgs/container/backup-utils) container registries.

```shell
# You can also specify a github run number as the tag, such as afonsoc12/backup-utils:2
docker pull afonsoc12/backup-utils:latest

# Should print the version of all the programs listed above
docker run --rm -it afonsoc12/backup-utils version

# You can use any of the tools as you would like
docker run --rm -it afonsoc12/backup-utils rclone lsd /s
```

## Running the container

The default command for the container is `sh -l`, which means that it will automatically exit if the flags `-it` are not set. If you'd like the container to stay alive, just pass `-it` along with `docker run` or add `tty: true` if using docker-compose. Any commands passed after the image name will override this behaviour.

There are multiple ways to use this container, select the one that suits you better! Here are two options that might work for most of the cases.

**Option 1:** running as a one-off command. It will spin-up the container, do what it has to do, and delete the container afterwards.

```shell
# Option 1: Run as one-off command
docker run --rm \
    -v /mnt/mydata:/mnt/mydata \
    -v $HOME/.config/rclone:/config/rclone \
    afonsoc12/backup-utils \
    rclone sync /mnt/mydata gdrive:backups/mydata
```

**Option 2:** run the container and keeping it alive (must have `-it` flags). Then use `docker exec` to execute tasks:

```shell
# Option 2: Keep container running and execute tasks with docker exec
docker run -d -it \
    --name backup-utils \
    -v /mnt/mydata:/mnt/mydata \
    -v $HOME/.config/rclone:/config/rclone \
    afonsoc12/backup-utils

# Execute inside the container
docker exec -it backup-utils \
        rclone sync /mnt/mydata gdrive:backups/mydata
```

Personally, I use **Option 1** to backup my k3s cluster (using Kubernetes CronJobs) and **Option 2** for standalone servers and Unraid.
Regarding the latter, it is also handy to define all mount volumes in docker-compose and simply schedule a task to run the backups with `docker exec`. Here is a snippet of a compose file.

```yaml
version: '3'

services:
    backup-utils:
        image: afonsoc12/backup-utils:latest
        container_name: backup-utils
        hostname: myserver
        environment:
            - TZ=Europe/London
        tty: true # Keeps container running
        volumes:
            - $HOME/.config/rclone:/config/rclone               # Rclone config
            - ~/.ssh:/root/.ssh:ro                     # ssh keys and config
            - $HOME/.cache/restic:/config/cache/restic # Persist restic local cache
            - /mnt:/mnt:ro                             # data to backup
        restart: unless-stopped
```

## Considerations for specific utilities

### Rsync
If using sftp with rsync, it is advised to only use [public key authentication](https://www.ssh.com/academy/ssh/public-key-authentication). For this, you must have your ssh private keys mounted in the container. Use the directive `-v $HOME/.ssh:/root/.ssh` along with your `docker run` command to do so.

### Rclone
For rclone, only the configuration file needs to be mounted in the container. The container defines `/config` as `XDG_CONFIG_HOME`, so rclone will be looking for its configurations at `/config/rclone`. If you would like to mount your `rclone.conf`, just add `-v $HOME/.config/rclone:/config/rclone` to your `docker run` command.

You can always opt for not use `rclone.conf` and define all remotes configuration using environment variables. Please consult the [official documentation](https://rclone.org/docs/) for more details.

Moreover, it is also possible to serve [rclone UI](https://rclone.org/gui/) from the container.

```shell
# By default uses user/password rclone/rclone
docker run -d \
    --name backup-utils \
    -p 5572:5572 \
    -v /mnt/mydata:/mnt/mydata \
    -v $HOME/.config/rclone:/config/rclone \
    afonsoc12/backup-utils \
    rclone rcd --rc-web-gui \
               --rc-web-gui-update \
               --rc-web-gui-force-update \
               --rc-web-gui-no-open-browser \
               --rc-addr :5572 \
               --rc-user rclone \
               --rc-pass rclone
```

### Restic

I strongly recommend parsing the host's hostname to the container, so that restic snapshots are shown with a consistent hostname. This can be achieved by simply adding `--hostname myserver` to docker.

Concerning caching, Restic stores [local cache](https://restic.readthedocs.io/en/stable/manual_rest.html#caching) inside the container in `$XDG_CACHE_HOME/restic`, which by default is expanded to `/cache/restic`. Therefore, adding the directive `-v $HOME/.cache/restic:/cache/restic` to `docker run` command allows to persist this cache and speedup incremental snapshots.

## Credits

Copyright 2022 Afonso Costa

Licensed under the [Apache License, Version 2.0](https://github.com/afonsoc12/backup-utils/blob/master/LICENSE) (the "License")
