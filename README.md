# 使用前需要：
- `系统有安装 rsync bc inotify-tools tar unzip vim git lrzsz 等常用软件.`
- `远端机器配置本机远程远端机免密登录.`
- `脚本与service 文件上传至对应目录.`
- `脚本中 本地目录、远端目录、远端机ssh端口、远端机地址、远端机用户名、同步检测间隔、日志文件路径 等参数自行修改.`
# 目录同步服务

这个项目包含一个目录同步脚本和对应的systemd服务配置，用于监控本地目录变化并同步到远程服务器。

## 文件说明

- `sync_directory.sh`: 同步脚本，用于监控本地目录变化并同步到远程服务器
- `sync-directory.service`: systemd服务单元文件，用于管理同步脚本

## 安装步骤

1. 将同步脚本复制到目标位置：

```bash
sudo cp sync_directory.sh /opt/onedev-data/
sudo chmod +x /opt/onedev-data/sync_directory.sh
```

2. 将systemd服务单元文件复制到系统目录：

```bash
sudo cp sync-directory.service /etc/systemd/system/
```

3. 重新加载systemd配置：

```bash
sudo systemctl daemon-reload
```

4. 启用并启动服务：

```bash
sudo systemctl enable sync-directory.service
sudo systemctl start sync-directory.service
```

## 服务管理

- 启动服务：`sudo systemctl start sync-directory.service`
- 停止服务：`sudo systemctl stop sync-directory.service`
- 重启服务：`sudo systemctl restart sync-directory.service`
- 查看服务状态：`sudo systemctl status sync-directory.service`
- 查看服务日志：`sudo journalctl -u sync-directory.service`

## 配置说明

同步脚本中的配置参数：

- `LOCAL_DIR`: 本地目录路径，默认为 `/opt/onedev-data`
- `REMOTE_USER`: 远程服务器用户名，默认为 `root`
- `REMOTE_HOST`: 远程服务器地址，默认为 `172.16.101.15`
- `REMOTE_DIR`: 远程目录路径，默认为 `/data/onedev-data`
- `SSH_PORT`: SSH端口，默认为 `22`
- `SYNC_INTERVAL`: 同步检测间隔（秒），默认为 `300`（5分钟）
- `LOG_FILE`: 日志文件路径，默认为 `/tmp/sync_directory.log`

如需修改这些配置，请编辑 `/opt/onedev-data/sync_directory.sh` 文件。