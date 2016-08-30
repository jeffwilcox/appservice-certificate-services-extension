//
// Copyright (c) Microsoft Corporation and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Web;
using System.Web.Http;

namespace AppService.CertificateServices.Certificates.Controllers
{
    public class HomeController : ApiController
    {
        private string GetClientIp(HttpRequestMessage request = null)
        {
            request = request ?? Request;

            if (request.Properties.ContainsKey("MS_HttpContext"))
            {
                return ((HttpContextWrapper)request.Properties["MS_HttpContext"]).Request.UserHostAddress;
            }
//            else if (request.Properties.ContainsKey(RemoteEndpointMessageProperty.Name))
  //          {
    //            RemoteEndpointMessageProperty prop = (RemoteEndpointMessageProperty)request.Properties[RemoteEndpointMessageProperty.Name];
      //          return prop.Address;
        //    }
            else if (HttpContext.Current != null)
            {
                return HttpContext.Current.Request.UserHostAddress;
            }
            else
            {
                return null;
            }
        }

        // GET /
        public string Get()
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine(GetClientIp(Request));

            foreach (var prop in Request.Properties)
            {
                //sb.AppendLine(string.Format("Property: {0}={1}", prop.Key, prop.Value.ToString()));
                if (prop.Value.ToString() == "MS_HttpContext")
                {
                    var ctx = prop.Value as HttpContextWrapper;
                    if (ctx != null)
                    {
                        var ip = ctx.Request.UserHostAddress;
                        sb.AppendLine("IP: " + ip.ToString());

                        sb.AppendLine("ILocal: " + ctx.Request.IsLocal.ToString());
                    }
                }
            }

            return sb.ToString();
        }
    }
}
