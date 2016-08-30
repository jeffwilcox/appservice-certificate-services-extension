//
// Copyright (c) Microsoft Corporation and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

using Microsoft.IdentityModel.Clients.ActiveDirectory;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace AppService.CertificateServices.Models
{
    public class LightweightAuthenticationResult
    {
        public string AccessToken { get; private set; }
        public string AccessTokenType { get; private set; }
        public DateTimeOffset ExpiresOn { get; private set; }

        public LightweightAuthenticationResult(AuthenticationResult result)
        {
            AccessToken = result.AccessToken;
            AccessTokenType = result.AccessTokenType;
            ExpiresOn = result.ExpiresOn;
        }
    }
}