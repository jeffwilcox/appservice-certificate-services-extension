# App Service Certificate Services Extension

This App Service Extension is designed to help build App Service applications that
use certificates for authentication operations such as Azure KeyVault.

This extension also includes an Advanced Tools endpoint for retrieving information
about any certificates available for use by the application, including a REST API
endpoint.

## Application - Local Authorization Process

`GetAuthorizationToken.exe` is a .NET console application that can be called 
by your web application via process management APIs.

The authorization token service takes in four required arguments:

- Thumbprints: A commma-separated list of the certificate thumbprints to consider for the authorization action.
- Tenant ID: The Azure Active Directory tenant ID to use for authentication.
- Client ID: The Azure Active Directory application ID to use for authorization with the resource.
- Resource: The resource name. For Azure KeyVault, this will be `vault.azure.net`.

The output of the application is either a JSON representation of the 
authorization token or an error is thrown, changing the exit code of 
the process.

## Web Service - Local Authorization Token Service

The local Certificate Service is an API endpoint that is exposed on 
your main web application as a virtual app and directory.

Ideally it would instead be exposed only to the local application 
pool and application, but due to the sandbox environment for Azure 
App Service at this time, this does not seem possible.

An Application Setting or environment variable can be used to lock 
down and reject all use of this API.

The service is implemented as an ASP.NET Web API project. It attaches 
to a randomly generated endpoint on the main web application for your 
site. It generates a secure local API key that allows the interprocess 
HTTPS communication between the app and the site.

The endpoint therefore is different each time that the extension 
is installed or updated. The main web app needs to be restarted after 
such an extension operation for the new environment variables to be 
updated. Note that the endpoint and application will return an HTTP 404 
if things do not feel quite right, as opposed to more standard error 
status codes.

This approach is probably a little too high overhead, but is 
interesting nonetheless.

The endpoint is: 

```
Authentication: Bearer :localApiKey
HTTP POST https://:appurl/:randomlyGeneratedPath/certificates/:thumbprints/tenant/:tenantId/client/:clientId/resource/:resource/authorize
```

## Configuration

### Config Options

- `CERTIFICATE_SERVICES_ALLOW_TEST_CERTIFICATES`: The value "0" to not allow test certificates. The default is to allow test certificates.

### Local Application Service On/Off

- `CERTIFICATE_SERVICES_ENDPOINT_ENABLED`: Setting to "0" will turn off the local service routes. Default is "1" - enabled. If you are using the process method of the app, you may want to turn this off.

### Application Environment Variables

Note that these environment variables are only exposed to the main 
application host. To prevent developer mistakes, the environment 
exposed to the Advanced Tools (Kudu) is actually redacted to make 
it much harder to get to.

- `CERTIFICATE_SERVICES_KEY_FILENAME`: The full path name to the active shared local authentication key to use for local service-to-service communication.
- `CERTIFICATE_SERVICES_ENDPOINT`: The web URL to the generated endpoint for the service.

## Developer Tools

The `/Certificates` endpoint exposed through Advanced Tools (Kudu, the `.scm` endpoint 
of your App Service) shows information about any and all certificates that have been 
made available to the web application.

Maybe this will eventually be a UI. Today it is just a simple REST API to learn about 
the certificates, and how long until the certs expire.

# Open source project information

## License

[MIT License](LICENSE)

## Code of Conduct

This project has adopted the [Microsoft Open Source Code of
Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct
FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com)
with any additional questions or comments.

## Governance

This project is a side project built to help build slightly better Node.js apps
on Azure by enabling use of certificate-based KeyVault operations.

Contributions welcome - do follow the Microsoft CLA process - and active, useful
contributions can be considered when making maintainer decisions as the project
continues.
