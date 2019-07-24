using f4core
using f4model
using f4parser

**
** This provider works when we completing something after "@"
**
class FacetCompletionProvider : CompletionProvider {

	//////////////////////////////////////////////////////////////////////////
	// Constructor and overrides
	//////////////////////////////////////////////////////////////////////////

	new make(IFanNamespace ns, Str src, CUnit unit) : super(ns, src, unit) {}
	
	override Bool setInput(Int pos, Str prefix) {
		super.setInput(pos, prefix)
		path := AstFinder.find(unit, pos)
		if (path.last is FacetDef) return true
		
		// fixes https://github.com/xored/f4/issues/98
		if (prefix.isEmpty && src[pos] == '@') return true

		return false
	}
	
	override Bool complete(CompletionReporter reporter) {
		super.complete(reporter)
		ns.podNames.each {
			pod := ns.findPod(it)
			pod.typeNames.findAll { it.lower.startsWith(prefix.lower) } .each {
				IFanType? type := pod.findType(it)
				if (type != null) {
					if (type.isFacet) {
						reportType(type)
					}
				}
			}
		}
		return true
	}
}
