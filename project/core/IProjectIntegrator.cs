using System;
using ThoughtWorks.CruiseControl.Remote;

namespace ThoughtWorks.CruiseControl.Core
{
	public interface IProjectIntegrator : IDisposable
	{
		// TODO look into whether the setters are required for these properties
		ISchedule Schedule { get; set; }
		IProject Project { get; set; }

		/// <summary>
		/// Starts the integration of this project on a separate thread.  If
		/// this integrator has already started, this method causes no action.
		/// </summary>
		void Start();

		/// <summary>
		/// Stops the integration of this project.
		/// </summary>
		void Stop();

		/// <summary>
		/// Waits for the project integrator thread to exit, and joins with it.
		/// </summary>
		void WaitForExit();

		/// <summary>
		/// Aborts the integrator thread immediately.
		/// </summary>
		void Abort();

		/// <summary>
		/// Gets a value indicating whether this project integrator is currently
		/// running.
		/// </summary>
		bool IsRunning
		{
			get;
		}

		/// <summary>
		/// Gets a value indicating the project integrator's current state.
		/// </summary>
		ProjectIntegratorState State
		{
			get;
		}
	}
}
