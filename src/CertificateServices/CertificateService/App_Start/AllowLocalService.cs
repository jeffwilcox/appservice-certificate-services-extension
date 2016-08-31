//
// Copyright (c) Microsoft Corporation and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace AppService.CertificateServices
{
    public class AllowLocalService
    {
        private const string AllowLocalCertificateServiceEnvironmentVariable = "CERTIFICATE_SERVICES_ENDPOINT_ENABLED";
        private const string TurnOffEnvironmentValue = "0";
        private const bool AllowLocalCertificateServiceDefaultValue = true;

        public static bool AllowLocalCertificateService
        {
            get
            {
                bool allowService = AllowLocalCertificateServiceDefaultValue;
                string testCertificatesValue = Environment.GetEnvironmentVariable(AllowLocalCertificateServiceEnvironmentVariableName);
                if (testCertificatesValue != null && testCertificatesValue == TurnOffEnvironmentValue)
                {
                    allowService = false;
                }
                return allowService;
            }
        }

        public static string AllowLocalCertificateServiceEnvironmentVariableName
        {
            get
            {
                return AllowLocalCertificateServiceEnvironmentVariable;
            }
        }
    }
}
