using f4core
using f4parser
using f4model

**
** Completes pod names and types in usings
**
class UsingCompletionProvider : CompletionProvider {

	//////////////////////////////////////////////////////////////////////////
	// Constructor and overrides
	//////////////////////////////////////////////////////////////////////////

	new make(IFanNamespace ns, Str str, CUnit unit) : super(ns, str, unit) {}
	
	override Bool setInput(Int pos, Str prefix) {
		super.setInput(pos, prefix)
		//We will use very simple technique - if we are outside of type 
		//and trimmed line starts with 'using'.
		//the it is our client
		path := AstFinder.find(unit, pos)
		if (path.find(TypeDef#) != null) return false

		line := ParseUtil.lineStart(src, pos).trim
		if (!line.startsWith("using") || line.index("[") != null) return false
		
		return true
	}
	
	override Bool complete(CompletionReporter reporter) {
		super.complete(reporter)
		reportNsPods
		return true
	}
}
