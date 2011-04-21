using f4core
using compiler
using concurrent

using [java]org.eclipse.dltk.launching::LibraryLocation
using [java]org.eclipse.dltk.launching::ScriptRuntime
using [java]org.eclipse.debug.core::ILaunchConfiguration
using [java]org.eclipse.debug.core.model::IProcess
using [java]org.eclipse.core.runtime::NullProgressMonitor
using [java]org.eclipse.debug.core::ILaunchManager

**
** Base class for builders
** 
abstract class Builder
{
  const FantomProject fp
  new make(FantomProject fp)
  {
    this.fp = fp
  }
  
  CompilerErr[] build(|Str|? consumer := null)
  {
    configErrs := [
        fp.projectErrs.map { projectErr(it) }, 
        fp.buildfanErrs.map { projectErr(it) }, 
        interpreterErrs
      ].flatten
    return configErrs.isEmpty ? buildPod(consumer) : configErrs
  }
  
  
  abstract CompilerErr[] buildPod(|Str|? consumer)
  
  private CompilerErr buildFanErr(ProjectErr e) 
  {
    CompilerErr.make(e.msg, Loc.makeFile(fp.baseDir + `$Manifest.filename`, e.line, 0), null, LogLevel.err)
  }
  
  protected CompilerErr[] interpreterErrs() 
  {
    fp.isInterpreterSet ? [,] : [projectErr(ProjectErr("Interpreter is not configured"))]
  }
  
  private CompilerErr projectErr(ProjectErr e)
  {
    CompilerErr.make(e.msg, Loc.makeFile(fp.baseDir , e.line, 0), null, LogLevel.err)
  }
  
  protected static Str:File getAllPods(FantomProject fp)
  {
    result :=  [:]
    
    //add interpreter libraries
    libLocs := ScriptRuntime.getLibraryLocations(fp.getInterpreterInstall) as LibraryLocation[]
    libLocs.each 
    {
      file := PathUtil.resolveLocalPath(it.getLibraryPath())
      result[file.basename] = file
    }
    
    //add workspace pods
    FantomProjectManager.instance.listProjects.each |FantomProject p|
    {
      result[p.podName] = (p.outDir.uri + `${p.podName}.pod`).toFile
    }
    
    //uncomment if necessary 
    //result.setAll(fp.depends)
    return result
  }
  
  protected StrBuf launch(ILaunchConfiguration wc, |Str|? consumer)
  {
    launch := wc.launch(ILaunchManager.RUN_MODE, NullProgressMonitor(), false, false)
    out := StrBuf()
    if (launch.getProcesses.isEmpty) return out
    process := launch.getProcesses.first as IProcess
    while(!process.isTerminated) Actor.sleep(25ms)
    report(consumer,out,process.getStreamsProxy.getOutputStreamMonitor.getContents)
    report(consumer,out,process.getStreamsProxy.getErrorStreamMonitor.getContents)
    return out
  }

  private static Void report(|Str|? consumer, StrBuf out, Str txt)
  {
    consumer?.call(txt);
    out.add(txt);
  }
}

class SpyCompilerLog : CompilerLog
{
  private |Str|? listener
  new make(|Str|? listener, OutStream out := Env.cur.out) : super(out) 
  {
    this.listener = listener
  }
}
