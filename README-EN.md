# Directory Synchronization Service

## Prerequisites
- Ensure your system has installed common utilities such as `rsync`, `bc`, `inotify-tools`, `tar`, `unzip`, `vim`, `git`, `lrzsz`, etc.
- Configure passwordless SSH login from the local machine to the remote server.
- Upload the script and service files to their corresponding directories.
- Edit the script to set parameters such as local directory, remote directory, SSH port, remote host, remote username, sync interval, and log file path as needed.

## Project Overview

This project provides a directory synchronization script and a corresponding systemd service configuration. It monitors changes in a local directory and synchronizes them to a remote server.

## File Description

- `sync_directory.sh`: The synchronization script, used to monitor local directory changes and sync them to the remote server.
- `sync-directory.service`: The systemd service unit file, used to manage the synchronization script.

## Installation Steps

1. Copy the synchronization script to the target location:

```bash
sudo cp sync_directory.sh /opt/onedev-data/
sudo chmod +x /opt/onedev-data/sync_directory.sh
```

2. Copy the systemd service unit file to the system directory:

```bash
sudo cp sync-directory.service /etc/systemd/system/
```

3. Reload the systemd configuration:

```bash
sudo systemctl daemon-reload
```

4. Enable and start the service:

```bash
sudo systemctl enable sync-directory.service
sudo systemctl start sync-directory.service
```

## Service Management

- Start the service: `sudo systemctl start sync-directory.service`
- Stop the service: `sudo systemctl stop sync-directory.service`
- Restart the service: `sudo systemctl restart sync-directory.service`
- Check service status: `sudo systemctl status sync-directory.service`
- View service logs: `sudo journalctl -u sync-directory.service`

## Configuration

Configuration parameters in the synchronization script:

- `LOCAL_DIR`: Local directory path, default is `/opt/onedev-data`
- `REMOTE_USER`: Remote server username, default is `root`
- `REMOTE_HOST`: Remote server address, default is `172.16.101.15`
- `REMOTE_DIR`: Remote directory path, default is `/data/onedev-data`
- `SSH_PORT`: SSH port, default is `22`
- `SYNC_INTERVAL`: Sync check interval (seconds), default is `300` (5 minutes)
- `LOG_FILE`: Log file path, default is `/tmp/sync_directory.log`

To modify these configurations, please edit the `/opt/onedev-data/sync_directory.sh` file.