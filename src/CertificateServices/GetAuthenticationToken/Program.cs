﻿//
// Copyright (c) Microsoft Corporation and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

using AppService.CertificateServices;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GetAuthenticationToken
{
    class Program
    {
        private readonly static TimeSpan TimeoutMaximum = TimeSpan.FromSeconds(15);

        static void Main(string[] args)
        {
            if (args.Length < 4)
            {
                throw new InvalidOperationException("Not enough arguments specified: [app] thumbprints tenantId clientId resource");
            }

            CertificatesRepository certificates = new CertificatesRepository();
            bool allowTestCertificates = AllowTestCertificatesSetting.AllowTestCertificates;

            string thumbprints = args[0];
            string tenantId = args[1];
            string clientId = args[2];
            string resource = args[3];

            var task = AuthenticationHelper.AuthorizeClient(certificates, allowTestCertificates, thumbprints, tenantId, clientId, resource);
            task.Wait(TimeoutMaximum);

            var result = task.Result;
            Console.WriteLine(JsonConvert.SerializeObject(result));
        }
    }
}
