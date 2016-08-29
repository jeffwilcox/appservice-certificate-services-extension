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
    public class AllowTestCertificatesSetting
    {
        private const string AllowTestCertificatesEnvironmentVariable = "WEBSITE_CERTIFICATE_SERVICE_ALLOW_TEST_CERTIFICATES";
        private const string TurnOffEnvironmentValue = "0";
        private const bool AllowTestCertificatesDefaultValue = true;

        public static bool AllowTestCertificates
        {
            get
            {
                bool allowTestCertificates = AllowTestCertificatesDefaultValue;
                string testCertificatesValue = Environment.GetEnvironmentVariable(AllowTestCertificatesEnvironmentVariable);
                if (testCertificatesValue != null && testCertificatesValue == TurnOffEnvironmentValue)
                {
                    allowTestCertificates = false;
                }
                return allowTestCertificates;
            }
        }

        public static string AllowTestCertificatesEnvironmentVariableName
        {
            get
            {
                return AllowTestCertificatesEnvironmentVariable;
            }
        }
    }
}
