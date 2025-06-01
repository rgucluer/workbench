For app1

<workbench_full_path>/dockerfiles/app1/nginx/conf.d/app.conf

Enter your domain name deleting myserver.com
```nginx
.....
server_name myserver.com default_server;
......
```

For app2


<workbench_full_path>/dockerfiles/app2/nginx/conf.d/app.conf

Enter your domain name deleting demo1.myserver.com
```nginx
.....
server_name demo1.myserver.com default_server;
......
```

Back to [Development Environment installation ](install-dev-2404.md#edit-nginx-config-files)
