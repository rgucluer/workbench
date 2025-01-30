## Add a Gatsby Blog to the Dswebdocs Workbench
- [Install nvm and node](install-nvm.md)
- Install Gatsby command line interface(install-gatsby-cli.md)
```bash
npm install -g gatsby-cli
```

- Choose one:
  - [Use an existing Gatsby Blog project](existing-gatsby-blog.md) 
  - [Create a new blog with gatsby command line interface](new-gatsby-blog.md)
- [Make changes to run the Gatsby blog with Dswebdocs Workbench.](make-changes-for-gatsby-dev.md)
- [Rebuild the project](rebuild-dev.md)
- Open web browser, and visit the following address
  - http://<domain_name_3>

### To make changes on the blog

#### Step One:
In order gatsby develop to work, node packages must already be installed. For any reason if the node_modules directory is empty, do the following:

  ```bash
  cd <workbench_full_path>/dockerfiles/gatsby
  ```

  ```bash
  npm install 
  ```
  If you get any errors, delete dockerfiles/gatsby/package-lock.json and try again.

  - Run gatsby develop
  ```bash
  gatsby develop
  ```

- Make changes in:
  - <workbench_directory>/dockerfiles/gatsby/content/blog/hello-world/index.md
  - For more information, read Gatsby documentation: [Writing pages in mdx](https://www.gatsbyjs.com/docs)

- See changes in:
  - http://localhost:8000/hello-world/
  - It takes a few seconds to see the change.

- Stop gatsby develop
  - Switch to the terminal running Gatsby develop, and press CTRL+C, release keys and wait for a few seconds.

#### Step two
- Use gatsby build to prepare content for production
  
  ```bash
  cd <workbench_full_path>/dockerfiles/gatsby
  ```
  ```bash
  gatsby build
  ```

  - [Rebuild Dswebdocs Workbench project](rebuild-dev.md)  to see the results in development environment (Using Virtual Machine and domain_name_3).
  - Workbench rebuild takes some time, please be patient.
  - Open a web browser and navigate to http://<domain_name_3> . Check results (Hit F5 if necessary).

Now, you can continue to [Production Environment installation](install-prod-2404.md).

### References:
- Gatsby
  - Documentation 
    - https://www.gatsbyjs.com/docs
    - https://www.gatsbyjs.com/docs/tutorial/getting-started/part-0/