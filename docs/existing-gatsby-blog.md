## Use an existing Gatsby Blog Template

Copy the template as gatsby
```bash
cd <workbench_directory>/dockerfiles
```
```bash
cp -r gatsby-template gatsby
```
```bash
cd gatsby
```
```bash
npm install
```
```bash
npx update-browserslist-db@latest
```
```bash
Need to install the following packages:
update-browserslist-db@1.1.1
Ok to proceed? (y) 
..... 
caniuse-lite has been successfully updated
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

## [Make changes to run the Gatsby blog with Dswebdocs Workbench.](make-changes-for-gatsby-dev.md)


[Back to README](../README.md)


### References:
- https://www.npmjs.com/package/gatsby
- https://github.com/gatsbyjs/gatsby


