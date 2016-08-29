using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http.Formatting;
using System.Web.Http;

namespace AppService.CertificateServices.Certificates
{
    public static class WebApiConfig
    {
        internal readonly static object AllowTestCertificatesKey = new object();

        public static void Register(HttpConfiguration config)
        {
            // Web API configuration and services
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
                name: "DefaultApi",
                routeTemplate: "api/{controller}/{id}",
                defaults: new { id = RouteParameter.Optional }
            );
        }
    }
}
