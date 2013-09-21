using Microsoft.Owin;
using Owin;

[assembly: OwinStartupAttribute(typeof(RootSite.Startup))]
namespace RootSite
{
    public partial class Startup 
    {
        public void Configuration(IAppBuilder app) 
        {
            ConfigureAuth(app);
        }
    }
}
