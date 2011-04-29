//import org.eclipse.jface.text.source.ISourceViewer;
//import com.xored.fanide.internal.ui.text.FanPairMatcher;
//import com.xored.fanide.internal.ui.text.IFanPartitions;

using [java] java.lang::Class
using [java] org.eclipse.swt.widgets::Composite
using [java] org.eclipse.ui::IEditorInput
using [java] org.eclipse.ui::IPageLayout
using [java] org.eclipse.ui.part::IShowInTargetList
using [java] org.eclipse.jface.preference::IPreferenceStore
using [java] org.eclipse.jface.text::IDocument
using [java] org.eclipse.jface.text::IDocumentExtension3
using [java] org.eclipse.jface.text::ITextViewerExtension
using [java] org.eclipse.jface.text.source::ICharacterPairMatcher
using [java] org.eclipse.jface.util::IPropertyChangeListener
using [java] org.eclipse.dltk.core::IDLTKLanguageToolkit
using [java] org.eclipse.dltk.ui::PreferenceConstants
using [java] org.eclipse.dltk.ui.text::ScriptTextTools
using "[java]org.eclipse.dltk.internal.ui.editor"::BracketInserter
using "[java]org.eclipse.dltk.internal.ui.editor"::ScriptOutlinePage
using "[java]org.eclipse.dltk.internal.ui.editor"::ScriptEditor
using [java] com.xored.fanide.core::FanLanguageToolkit
using "[java]com.xored.fanide.internal.ui"::FanUI

class FanEditor : ScriptEditor
{
  override Str? getEditorId := "com.xored.fanide.ui.editor.FanEditor" { private set }

  public static const Str editorCtx := "#FanEditorContext"
  public static const Str rulerCtx := "#FanRulerContext"

  private BracketInserter bracketInserter := FanBracketInserter(this)
  private IPreferenceStore store := FanUI.getDefault.getPreferenceStore

  protected override Void initializeEditor()
  {
    super.initializeEditor
    setEditorContextMenuId(editorCtx)
    setRulerContextMenuId(rulerCtx)
  }

  override IPreferenceStore? getScriptPreferenceStore()
  {
    FanUI.getDefault.getPreferenceStore
  }

  override ScriptTextTools? getTextTools() { FanTextTools.instance }

  protected override ScriptOutlinePage? doCreateOutlinePage()
  {
    FanOutlinePage(this, FanUI.getDefault.getPreferenceStore)
  }

  protected override Void connectPartitioningToElement(
    IEditorInput? input, IDocument? document)
  {
    if (document isnot IDocumentExtension3) return
    extension := (IDocumentExtension3)document
    if (extension.getDocumentPartitioner(IFanPartitions.partitioning) == null)
      FanDocumentSetupParticipant().setup(document)
  }

  override Void createPartControl(Composite? parent)
  {
    super.createPartControl(parent)

    bracketInserter.setCloseBracketsEnabled(store
        .getBoolean(PreferenceConstants.EDITOR_CLOSE_BRACKETS))
    bracketInserter.setCloseStringsEnabled(store
        .getBoolean(PreferenceConstants.EDITOR_CLOSE_STRINGS))
    if (bracketInserter is IPropertyChangeListener)
      store.addPropertyChangeListener((FanBracketInserter) bracketInserter)
    /*
     * FIXME fBracketInserter is added as PropertyChangeListener but never
     * removed. Another way is just override handlePreferenceStoreChanged()
     * or move most of the code to the base editor class.
     */

    (getSourceViewer as ITextViewerExtension)?.prependVerifyKeyListener(bracketInserter)
  }

  override IDLTKLanguageToolkit? getLanguageToolkit() { FanLanguageToolkit.getDefault }

  override const Str? getCallHierarchyID := "org.eclipse.dltk.callhierarchy.view"

  protected override Void initializeKeyBindingScopes()
  {
    setKeyBindingScopes(["org.eclipse.dltk.ui.FanEditorScope"])
  }

  protected override ICharacterPairMatcher? createBracketMatcher() { FanPairMatcher() }

  override Obj? getAdapter(Class? required)
  {
    if (required == IShowInTargetList#->toClass)
      return idem |->Str?[]?| { [ FanUI.ID_FAN_EXPLORER, IPageLayout.ID_OUTLINE ] }
    return super.getAdapter(required)
  }
  
  private IShowInTargetList idem(IShowInTargetList x) { x }
}
