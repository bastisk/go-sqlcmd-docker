# go-sqlcmd Docker

This Repository provides the sqlcmd (Go) command line tool by Microsoft (https://github.com/microsoft/go-sqlcmd) as a docker image.

## Example Usage

### Basic usage
Similar to `mcr.microsoft.com/mssql-tools`, only that it doesn't use `bash`, but `sh` as the default shell.

```
docker pull bastisk/go-sqlcmd:latest
docker run -it bastisk/go-sqlcmd:latest
~ $ sqlcmd
```

### Running a SQL script

This might be the most common use case, automatically applying a sql script to a given database from within Docker!

Check out [this directory](examples/Scripting/) for an example implementation.



1. Create a shell script and a sql file with the query to run.

a) script.sql
```sql
SELECT * FROM TABLE;
```

b) script.sh
```sh
sqlcmd -S <srv> -d <db> --authentication-method ActiveDirectoryServicePrincipal -U "<clientid>@<tenantid>" -P <pw> -i /script.sql
```
2. Create a custom Dockerfile

```Dockerfile
FROM bastisk/go-sqlcmd:latest

COPY script.sh /script.sh
COPY script.sql /script.sql
CMD ["bash", "/script.sh"]
```
3. Use the container however you see fit!


### Using Kubernetes

#### Running as a job

Run a command using a kubernetes job, see [this example](examples/kubernetes-job.yaml).

#### Manually run commands
**TL;DR**: take a look [here](examples/kubernetes-sqltools-debug.yaml) for the yaml!

- you could use this to get the pod running (and keep it running)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sqltools-debugger
spec:
  selector:
    matchLabels:
      app: sqltools
  replicas: 1
  template:
    metadata:
      labels:
        app: sqltools
    spec:
      containers:
        - name: sqltools
          image: bastisk/go-sqlcmd:latest
          command: [ "/bin/sh", "-c", "--" ]
          args: [ "while true; do sleep 30; done;" ]
      restartPolicy: Never
```
- next, you can simply run `sh` in the pod and do stuff with sqlcmd, for example like so:

```bash
> kubectly apply -f sqltools.yaml # this is the yaml above
deployment.apps/sqltools-debugger created

> kubectl get pods
NAME                                  READY   STATUS                       RESTARTS   AGE
smartspacesingress-6cfb685555-gmsw8   1/1     Running                      0          84m

> kubectl exec -it sqltools-debugger-6d6f6f5d88-xvp56 -- sh
~ $ sqlcmd  -S <server> -d <db> -U <principalId>@<tenantId> -P <password> --authentication-method ActiveDirectoryServicePrincipal
```

- if you are done, remember to delete the pod

```bash
> kubectl delete -f sqltools.yaml
deployment.apps "sqltools-debugger" deleted

```