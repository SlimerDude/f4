
// FIXME rename to F4LaunchEnv?
** An Env for F4 launched applications.
** 
** All F4 generated pods are passed in via the 'FAN_ENV_PODS' environment variable.
** 
** Any previously set 'FAN_ENV' is passed in via the 'FAN_ENV_PARENT' environment variable 
** and becomes the parent 'Env'. This preserves any 'PATH_ENV' that has been set on the system.
const class F4PodEnv : Env {

	static new make() {
		// Env.cur defaults to BootEnv until we create ourselves
		podLocs		:= Env.cur.vars["FAN_ENV_PODS"]?.trimToNull?.split(File.pathSep.chars.first, true) ?: Str#.emptyList
		origFanEnv	:= Env.cur.vars["FAN_ENV_PARENT"]?.trimToNull

		// a handy get out of jail card 'cos eclipse *forces* you to provide a value for environment variables
		if (origFanEnv != null && origFanEnv.equalsIgnoreCase("null"))
			origFanEnv = null

		curEnv		:= origFanEnv != null ? Type.find(origFanEnv).make : Env.cur
		return makeInternal(podLocs, curEnv)
	}
	
	private const Str:File podLocations
	
	private new makeInternal(Str[] podLocs, Env parent) : super.make(parent) {
		podLocations = Str:File[:] { it.ordered=true }.addList(podLocs.map { File.os(it) }) { it.basename }
		podLocations.vals.each {
			if (!it.exists)
				throw Err("Pod file does not exist - ${it.osPath}")
		}
	}

	override File? findPodFile(Str podName) {
		podLocations[podName] ?: super.findPodFile(podName)
	}
	
	override Str[] findAllPodNames() {
		podLocations.keys.addAll(super.findAllPodNames).unique
	}
}
