//
// Copyright (c) Microsoft Corporation and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography.X509Certificates;
using System.Web;

namespace AppService.CertificateServices.Models
{
    public class Certificate
    {
        public Certificate()
        {

        }

        public bool HasPrivateKey { get; private set; }
        public string Issuer { get; private set; }
        public DateTime NotBefore { get; private set; }
        public DateTime NotAfter { get; private set; }
        public string Subject { get; private set; }
        public string Thumbprint { get; private set; }


        public static Certificate FromX509Certificate2(X509Certificate2 cert)
        {
            return new Certificate
            {
                HasPrivateKey = cert.HasPrivateKey,
                Issuer = cert.Issuer,
                NotAfter = cert.NotAfter,
                NotBefore = cert.NotBefore,
                Subject = cert.Subject,
                Thumbprint = cert.Thumbprint,
            };
        }
    }
}