## Make changes in Dswebdocs Workbench for Gatsby development environment

Now, we will make changes in Gatsby blog to run it with Dswebdocs Workbench .

### Edit <workbench_directory>/ansible/inventory
Uncomment vars about Gastby
```yaml
---
prod_servers:
.....
all:
  vars:
    .....

    docker_gatsby_image_name: gatsbyimg
    docker_gatsby_image_version: "5.14.0"
    gatsby_directory_name: gatsby        
```

### Modify dockerfiles/gatsby/gatsby-config.js to your setup.

You can change the values about your site:
(Do not change plugin's resolve values, they define the scope of their options)

```json
.....
module.exports = {
  siteMetadata: {
    title: `Gatsby Starter Blog`,
    author: {
      name: `Kyle Mathews`,
      summary: `who lives and works in San Francisco building useful things.`,
    },
    description: `A starter blog demonstrating what Gatsby can do.`,
    siteUrl: `https://gatsbystarterblogsource.gatsbyjs.io/`,
    social: {
      twitter: `kylemathews`,
    },
  },
  plugins: [
    .....
    {
      resolve: `gatsby-plugin-feed`,
      options: {
        .....
        feeds: [
          {
            .....
            output: "/rss.xml",
            title: "Gatsby Starter Blog RSS Feed",
          },
    .....
    {
      resolve: `gatsby-plugin-manifest`,
      options: {
        name: `Gatsby Starter Blog`,
        short_name: `Gatsby`,
        .....
        icon: `src/images/gatsby-icon.png`, // This path is relative to the root of the site.
      },
    },
  ],
}
```
You can also edit content files in dockerfiles/gatsby/content/blog directory.

Refer to https://www.gatsbyjs.com/ site for more information.

Tutorial will work even if you don't change anything.

### Modify <workbench_directory>/ansible/tasks/dockerrebuild.yml . 
- Build Gatsby image tasks .

```bash
.....
    - name: Build gatsby image
      community.docker.docker_image:
        name: "{{ docker_gatsby_image_name }}"
        build:
          dockerfile: Dockerfile
          path: "/home/{{ ansible_user }}/dockerfiles/{{ gatsby_directory_name }}"
        state: present
        repository: "{{ docker_gatsby_image_name }}:{{ docker_gatsby_image_version }}"
        source: build
        tag: "{{ docker_gatsby_image_version }}"
        push: false        
```

### Create directories, and files
- If you used gatsby-template for creating this Gatsby Blog then skip to modifying gatsby-development service .
- Create the following directories chen using gatsby cli. We get some files from gatsby-template. 
```bash
cd <workbench_directory>/dockerfiles
```
```bash
cp gatsby-template/Dockerfile gatsby/
```

```bash
cp -r gatsby-template/nginx gatsby/
```


### Uncomment and modify gatsby-development service in dockerfiles/compose.yml

#### Development Environment:
```yaml
.....
services:
  .....
  gatsby-development:
    profiles: ["development"]
    build:
      context: "./gatsby"
      dockerfile: Dockerfile
      args:
        virtual_host: "myserver.com"
    .....
    volumes:
      ......
      - type: bind
        source: "/home/vmuser/dockerfiles/gatsby/public"
    labels:
      traefik.enable: true
      traefik.http.routers.gatsby-https.rule: "Host(`myserver.com`)"
      .....
      traefik.http.routers.gatsby-https.tls.domains[0].main: "myserver.com"
      ......
```

Now, you can continue to [Rebuild the project](rebuild-dev.md).



