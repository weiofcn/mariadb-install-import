# mariadb-install-import

- [X] 运行`sudo bash mariadb.sh`；
- [X] 更新mariadb的源为中国区域，ubunut系统版本自动检测切换；
- [X] 支持选择数据版本`MARIADB_VERSION`；
- [X] 设置root密码`MYSQL_ROOT_PASSWORD`；
- [X] 新建用户和密码`MYSQL_USER`，`MYSQL_PASSWORD`；
- [X] 支持多个数据库导入`MYSQL_DATABASE`（空格隔开），需要将SQL文件放到目录`db-dump`下；
- [ ] 导入数据量大的SQL文件很慢；
