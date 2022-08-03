<div align="center">
  <a href="https://christiandeleon.me/">
    <img src="images/logo192.png" alt="Logo" height="80">
  </a>

   <h1 align="center">My Personal Portfolio Infrastructure</h1>
   <a href="https://christiandeleon.me/"><strong>Visit my Portfolio Website</strong></a>

</div>

## About this Project

With the idea of showing off my skills, I have created a repository to list all of the ways I have designed infrastructures that run my portfolio using different IaC and cloud resources.

You can find that repository here: https://github.com/christian-deleon/portfolio-iac

The front end was designed and developed by me using React.Js, Javascript, HTML, and CSS.

Frontend Repository: https://github.com/christian-deleon/portfolio

Using `Terraform` with a serverless architecture I have created a very simple application that consists of the following AWS resources:

- `AWS S3` as the backend server
- `AWS CloudFront` as the CDN ( Content Delivery Network )
- `AWS Route 53` for the domain name services
- `AWS CodePipeline` for the CI/CD ( Continuous Integration and Continuous Delivery )
- `AWS CodeBuild` which takes changes from the respective GitHub repository and builds the React application
- `AWS CodeDeploy` to deploy the application to the AWS S3 bucket running as the application backend
