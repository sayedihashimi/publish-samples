using Microsoft.Owin;
using Owin;

[assembly: OwinStartupAttribute(typeof(AdminArea.Startup))]
namespace AdminArea
{
    public partial class Startup 
    {
        public void Configuration(IAppBuilder app) 
        {
            ConfigureAuth(app);
        }
    }
}
