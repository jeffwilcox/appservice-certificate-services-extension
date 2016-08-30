//
// Copyright (c) Microsoft Corporation and contributors. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography.X509Certificates;
using System.Web;

namespace AppService.CertificateServices
{
    public class CertificatesRepository
    {
        private StoreName storeName;
        private StoreLocation storeLocation;

        public CertificatesRepository()
        {
            storeName = StoreName.My;
            storeLocation = StoreLocation.CurrentUser;
        }

        public X509Certificate2 GetBestValidByThumbprints(string thumbprints, bool allowTestCertificates)
        {
            if (string.IsNullOrWhiteSpace(thumbprints))
            {
                throw new ArgumentException("At least one thumbprint must be provided.", "thumbprints");
            }

            // remove : from thumbprints - openssl by default outputs the separators
            var prints = thumbprints.Replace(":", "").Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);

            bool validateCertificates = !allowTestCertificates;
            X509Store store = new X509Store(storeName, storeLocation);
            try
            {
                store.Open(OpenFlags.ReadOnly);
                var certificates = store.Certificates.Find(X509FindType.FindByTimeValid, DateTime.Now, validateCertificates);
                if (prints.Length == 1)
                {
                    certificates = certificates.Find(X509FindType.FindByThumbprint, prints[0], validateCertificates);
                }
                if (certificates == null || certificates.Count == 0)
                {
                    return null;
                }
                if (certificates.Count == 1)
                {
                    return certificates[0];
                }
                var printSet = new HashSet<string>(prints);
                return certificates
                    .Cast<X509Certificate2>()
                    .Where(cert => cert.HasPrivateKey == true && printSet.Contains(cert.Thumbprint))
                    .OrderByDescending(cert => cert.NotAfter).FirstOrDefault();
            }
            finally
            {
                store.Close();
            }
        }

        public IEnumerable<X509Certificate2> GetAllValid(bool allowTestCertificates = true)
        {
            bool validateCertificates = !allowTestCertificates;
            X509Store store = new X509Store(storeName, storeLocation);
            try
            {
                store.Open(OpenFlags.ReadOnly);
                var certificates = store.Certificates.Find(X509FindType.FindByTimeValid, DateTime.Now, validateCertificates);
                if (certificates == null || certificates.Count == 0)
                {
                    return new X509Certificate2[] { };
                }
                return certificates.Cast<X509Certificate2>().ToList();
            }
            finally
            {
                store.Close();
            }
        }
    }
}