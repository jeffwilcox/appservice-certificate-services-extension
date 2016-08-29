//
// Copyright (c) Microsoft Corporation and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Web.Http;
using System.Web.Http.Routing;

namespace AppService.CertificateServices.CertificateService
{
    public static class WebApiConfig
    {
        internal readonly static object AllowTestCertificatesKey = new object();


        public static void Register(HttpConfiguration config)
        {
            // Only requests with local system knowledge via a shared key are allowed
            config.Filters.Add(new LocalApiKeyAttribute());

            config.Properties[AllowTestCertificatesKey] = AllowTestCertificatesSetting.AllowTestCertificates;

            // Always JSON
            var jsonFormatter = new JsonMediaTypeFormatter();
            config.Services.Replace(typeof(IContentNegotiator), new JsonContentNegotiator(jsonFormatter));

            // Web API routes
            config.MapHttpAttributeRoutes();

            config.Routes.MapHttpRoute(
                name: "Home",
                routeTemplate: "",
               defaults: new { controller = "Home" }
           );
            config.Routes.MapHttpRoute(
                name: "CertificatesActionRoute",
                routeTemplate: "certificates/{thumbprints}/tenant/{tenantId}/client/{clientId}/resource/{resource}/authenticate",
                defaults: new
                {
                    controller = "Certificates",
                    action = "AuthorizeClient",
                }
            );
            config.Routes.MapHttpRoute(
                name: "CertificatesRoute",
                routeTemplate: "certificates/{thumbprints}",
                defaults: new
                {
                    controller = "Certificates",
                    thumbprints = RouteParameter.Optional,
                }
            );
        }
    }
}
