## SetUp
### Install [sqitch](https://sqitch.org/)
```
$ aptitude install sqitch
```

### Configure sqitch
```
$ sqitch config --user user.name "Name"
$ sqitch config --user user.email "email"
$ sqitch config --bool deploy.verify true
$ sqitch config --bool rebase.verify true 
```

### Create DB
```
$ createdb -U root marketplace
```

### Add target to ~/.sqitch/sqitch.conf
```
[target "marketplace"]
    uri = db:pg://user:pass@localhost/marketplace
```

## Use sqitch

### Check status
```
$ sqitch status marketplace
```

### Deploy
```
$ sqitch deploy marketplace
```

### Verify
```
$ sqitch verify marketplace
```

