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
    public class CertificatesController : ApiController
    {
        private const string MicrosoftOnlineAuthorityEndpoint = "https://login.microsoftonline.com/{0}";
        
        private CertificatesRepository certificates;

        public CertificatesController()
        {
            certificates = new CertificatesRepository();
        }

        public CertificatesController(CertificatesRepository certificatesRepository)
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

        // GET /certificates
        public IEnumerable<Certificate> GetAll()
        {
            return certificates.GetAllValid(AllowTestCertificates).Select(cert => Certificate.FromX509Certificate2(cert));
        }

        // GET /certificates/:thumbprints
        public Certificate Get(string thumbprints)
        {
            var cert = certificates.GetBestValidByThumbprints(thumbprints, AllowTestCertificates);
            if (cert == null)
            {
                return null;
            }
            return Certificate.FromX509Certificate2(cert);
        }
    }
}
