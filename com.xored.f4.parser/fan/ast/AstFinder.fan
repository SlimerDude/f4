class AstFinder : AstVisitor
{
  private Node[] path
  private Int? pos
  private new make(Int? pos := null, Node[] path := Node[,]) 
  {
    this.pos = pos
    this.path = path
  }
  
  static AstPath find(CUnit unit, Int pos)
  {
    finder := AstFinder(pos)
    unit.accept(finder)
    return AstPath(finder.path, pos)
  }
  static AstPath findNode(Node node, Int pos)
  {
    finder := AstFinder(pos)
    node.accept(finder)
    return AstPath(finder.path, pos)
  }
  
  override Bool enterNode(Node node)
  { 
    if (node.start <= pos && pos <= node.end)
    {
      path.push(node)
      return true
    }
    return false
  }
}