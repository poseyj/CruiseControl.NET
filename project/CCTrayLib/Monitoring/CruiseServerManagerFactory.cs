using ThoughtWorks.CruiseControl.CCTrayLib.Configuration;
using ThoughtWorks.CruiseControl.Remote;

namespace ThoughtWorks.CruiseControl.CCTrayLib.Monitoring
{
	public class CruiseServerManagerFactory : ICruiseServerManagerFactory
	{
		private ICruiseManagerFactory cruiseManagerFactory;

		public CruiseServerManagerFactory(ICruiseManagerFactory cruiseManagerFactory)
		{
			this.cruiseManagerFactory = cruiseManagerFactory;
		}

		public ICruiseServerManager Create(BuildServer buildServer)
		{		
			if (buildServer.Transport == BuildServerTransport.Remoting)
			{
				return new RemotingCruiseServerManager(cruiseManagerFactory.GetCruiseManager(buildServer.Url), buildServer);
			}
			else
			{
				return new HttpCruiseServerManager(new WebRetriever(), new DashboardXmlParser(), buildServer);
			}
		}
	}
}