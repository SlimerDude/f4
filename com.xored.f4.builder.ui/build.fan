using build
class Build : build::BuildPod
{
  new make()
  {
    podName = "f4builderUI"
    summary = ""
    srcDirs = [`fan/`]
    depends = ["sys 1.0", "f4core 1.0", "f4builder 1.0", "concurrent 1.0"]
    outPodDir = `./`
  }
}
