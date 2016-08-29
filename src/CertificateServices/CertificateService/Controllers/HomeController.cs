//
// Copyright (c) Microsoft Corporation and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace AppService.CertificateServices.CertificateService.Controllers
{
    public class HomeController : ApiController
    {
        // GET /
        public IEnumerable<string> Get()
        {
            return new string[] { "certificates" };
        }
    }
}
