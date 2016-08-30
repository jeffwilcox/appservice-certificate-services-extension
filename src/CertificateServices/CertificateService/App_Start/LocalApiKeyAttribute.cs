//
// Copyright (c) Microsoft Corporation and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Security;
using System.Threading;
using System.Threading.Tasks;
using System.Web;
using System.Web.Http;
using System.Web.Http.Controllers;
using System.Web.Http.Filters;

namespace AppService.CertificateServices
{
    public class LocalApiKeyAttribute : AuthorizationFilterAttribute
    {
        private const string AppServiceHome = "HOME";
        private const string CertificateServiceLocalApiKeyFilename = "CERTIFICATE_LOCAL_SERVICE_FILENAME";

        private const string AuthorizationHeader = "Authorization";
        private const string AuthorizationBearerTokenPrefix = "Bearer ";

        private string GetSharedApiKey()
        {
            string apiKeyFilename = Environment.GetEnvironmentVariable(CertificateServiceLocalApiKeyFilename);
            string siteRoot = Environment.GetEnvironmentVariable(AppServiceHome);
            if (string.IsNullOrWhiteSpace(apiKeyFilename) || string.IsNullOrWhiteSpace(siteRoot))
            {
                throw new InvalidOperationException("No local service filename configured to share with applications.");
            }
            var dir = Path.Combine(siteRoot, "site");
            var certPath = Path.Combine(dir, apiKeyFilename);
            if (File.Exists(certPath))
            {
                return File.ReadAllText(certPath).Trim();
            }
            return null;
        }

        public override void OnAuthorization(HttpActionContext actionContext)
        {
            bool ok = false;

            try
            {
                string sharedApiKey = GetSharedApiKey();
                if (string.IsNullOrWhiteSpace(sharedApiKey))
                {
                    throw new SecurityException("Invalid authentication key configuration.");
                }

                IEnumerable<string> values;
                if (actionContext.Request.Headers.TryGetValues(AuthorizationHeader, out values))
                {
                    string first = values.FirstOrDefault();
                    if (first != null && first.Substring(AuthorizationBearerTokenPrefix.Length) == sharedApiKey)
                    {
                        ok = true;
                    }
                }
            }
            catch (Exception)
            {
                ok = false;
            }
            if (ok == true)
            {
                return;
            }
            throw new HttpResponseException(new HttpResponseMessage
            {
                StatusCode = HttpStatusCode.NotFound,
            });
        }
    }
}
