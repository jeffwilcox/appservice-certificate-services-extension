//
// Copyright (c) Microsoft Corporation and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

using Microsoft.IdentityModel.Clients.ActiveDirectory;
using AppService.CertificateServices.CertificateService.Models;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Threading.Tasks;
using System.Web;
using System.Web.Http;
using AppService.CertificateServices.Models;

namespace AppService.CertificateServices.CertificateService.Controllers
{
    public class TokensController : ApiController
    {
        private const string MicrosoftOnlineAuthorityEndpoint = "https://login.microsoftonline.com/{0}";
        
        private CertificatesRepository certificates;

        public TokensController()
        {
            certificates = new CertificatesRepository();
        }

        public TokensController(CertificatesRepository certificatesRepository)
        {
            certificates = certificatesRepository;
        }

        private bool AllowTestCertificates
        {
            get
            {
                return (bool)ControllerContext.Configuration.Properties[WebApiConfig.AllowTestCertificatesKey];
            }
        }

        private string CreateResourceString(string resource)
        {
            // Assumption:
            // Note that the Active Directory library does not take an object of type Uri,
            // but rather string. We do assume that a resource is a Uri, and if we construct
            // it, we require that it be an SSL endpoint. If that fails, it is returned
            // as-is.
            Uri resourceUri;
            if (Uri.TryCreate(resource, UriKind.Absolute, out resourceUri))
            {
                return resource;
            }

            string endpoint = string.Format(CultureInfo.InvariantCulture, "https://{0}", resource);
            if (Uri.TryCreate(endpoint, UriKind.Absolute, out resourceUri))
            {
                if (resourceUri.Scheme == Uri.UriSchemeHttps)
                {
                    return endpoint;
                }
            }
            return resource;
        }

        [HttpPost]
        public async Task<LightweightAuthenticationResult> AuthorizeClient(string thumbprints, string tenantId, string clientId, string resource)
        {
            var cert = certificates.GetBestValidByThumbprints(thumbprints, AllowTestCertificates);
            if (cert == null)
            {
                throw new InvalidOperationException("The certificate is not available.");
            }

            ClientAssertionCertificate certCred = new ClientAssertionCertificate(clientId, cert);
            string authority = string.Format(CultureInfo.InvariantCulture, MicrosoftOnlineAuthorityEndpoint, tenantId);
            AuthenticationContext authContext = new AuthenticationContext(authority, true, TokenCache.DefaultShared);

            string resourceIdentifier = CreateResourceString(resource);
            AuthenticationResult result = await authContext.AcquireTokenAsync(resourceIdentifier, certCred);
            return new LightweightAuthenticationResult(result);
        }
    }
}
