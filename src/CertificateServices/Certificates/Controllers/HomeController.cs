﻿//
// Copyright (c) Microsoft Corporation and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Web.Http;

namespace AppService.CertificateServices.Certificates.Controllers
{
    public class HomeController : ApiController
    {
        // GET /
        public string Get()
        {
            StringBuilder sb = new StringBuilder();

            sb.AppendLine(string.Format("IsLocal", Request.IsLocal()));

            foreach (var prop in Request.Properties)
            {
                sb.AppendLine(string.Format("Property: {0}={1}", prop.Key, prop.Value.ToString()));
            }

            return sb.ToString();
        }
    }
}
