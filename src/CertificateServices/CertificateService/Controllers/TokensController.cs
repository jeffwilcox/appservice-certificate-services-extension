//
// Copyright (c) Microsoft Corporation and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

using Microsoft.IdentityModel.Clients.ActiveDirectory;
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

        [HttpPost]
        public async Task<LightweightAuthenticationResult> AuthorizeClient(string thumbprints, string tenantId, string clientId, string resource)
        {
            return await AuthenticationHelper.AuthorizeClient(certificates, AllowTestCertificates, thumbprints, tenantId, clientId, resource);
        }
    }
}
