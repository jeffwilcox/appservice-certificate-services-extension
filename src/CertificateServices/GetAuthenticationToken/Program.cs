using AppService.CertificateServices;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GetAuthenticationToken
{
    class Program
    {
        static void Main(string[] args)
        {
            CertificatesRepository certificates = new CertificatesRepository();
            if (args.Length < 4)
            {
                throw new InvalidOperationException("Not enough arguments specified: [app] thumbprints tenantId clientId resource");
            }

            bool allowTestCertificates = AllowTestCertificatesSetting.AllowTestCertificates;

            string thumbprints = args[0];
            string tenantId = args[1];
            string clientId = args[2];
            string resource = args[3];

            var task = AuthenticationHelper.AuthorizeClient(certificates, allowTestCertificates, thumbprints, tenantId, clientId, resource);

        }
    }
}
