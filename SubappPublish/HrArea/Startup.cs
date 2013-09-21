using Microsoft.Owin;
using Owin;

[assembly: OwinStartupAttribute(typeof(HrArea.Startup))]
namespace HrArea
{
    public partial class Startup 
    {
        public void Configuration(IAppBuilder app) 
        {
            ConfigureAuth(app);
        }
    }
}
