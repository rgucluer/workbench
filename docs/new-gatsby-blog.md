## Create a new Gatsby blog

### Create a new blog with gatsby-cli
```bash
cd <workbench_directory>/dockerfiles
```

```bash
npx gatsby new gatsby https://github.com/gatsbyjs/gatsby-starter-blog
```

```bash
cd gatsby
```

```bash
npx update-browserslist-db@latest
```
```bash
Need to install the following packages:
update-browserslist-db@1.1.1
Ok to proceed? (y) 
```
Enter to continue. It will install a new version the package. Actually it could not update the package. Return to the old one. It has a problem, version returns to 1.0.30001690. Let's continue ...

Close all terminals. Open a new terminal ...

```bash
cd <workbench_directory>/dockerfiles/gatsby
```

```bash
gatsby develop
```

Check http://localhost:8000/

Check http://localhost:8000/___graphql

To stop press CTRL+C in terminal.

To prepare for production use, let's build

```bash
gatsby build
```

[Continue Gatsby blog integration](install-dev-2404.md#add-a-gatsby-blog-to-the-dswebdocs-workbench)

### References:
- https://www.npmjs.com/package/gatsby
- https://github.com/gatsbyjs/gatsby
- https://www.gatsbyjs.com/starters/gatsbyjs/gatsby-starter-blog


