#Requires AutoHotkey v2.0

; IntelliSense declarations for SAP wrapper classes.
class SapGuiBootstrap {
    static AttachROT()
    static GetScriptingEngineFromROT()
    static CreateScriptingControl()
    static CreateWrappedApplication(policy := "", strict := false, useRot := true)
}

class GuiComponentType {
}

class GuiComponent extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "")
    ContainerType {
        get
    }
    Id {
        get
    }
    Name {
        get
    }
    Parent {
        get
    }
    Type {
        get
    }
    TypeAsNumber {
        get
    }
}

class GuiContainer extends GuiComponent {
    __New(comObj, policy := "", strict := false, path := "")
    FindById(id, raise := unset)
    Children {
        get
    }
}

class GuiVContainer extends GuiContainer {
    __New(comObj, policy := "", strict := false, path := "")
    FindAllByName(name, type := unset)
    FindAllByNameEx(name, type := unset)
    FindByName(name, type := unset)
}

class GuiShell extends GuiVContainer {
    __New(comObj, policy := "", strict := false, path := "")
    SelectContextMenuItem(functionCode)
    SelectContextMenuItemByPosition(position)
    SelectContextMenuItemByText(text)
    AccDescription {
        get
    }
    CurrentContextMenu {
        get
    }
    DragDropSupported {
        get
    }
    Handle {
        get
    }
    OcxEvents {
        get
    }
    SubType {
        get
    }
}

class GuiAbapEditor extends GuiShell {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiApoGrid extends GuiShell {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiApplication extends GuiContainer {
    __New(comObj, policy := "", strict := false, path := "/app")
    AddHistoryEntry(entry)
    CreateGuiCollection()
    DropHistory()
    Ignore(type := unset, value := unset)
    OpenConnection(description, sync := unset)
    OpenConnectionByConnectionString(connectionString, sync := unset)
    RegisterROT()
    RevokeROT()
    ActiveSession {
        get
    }
    AllowSystemMessages {
        get
        set
    }
    Connections {
        get
    }
    ConnectionErrorText {
        get
    }
    HistoryEnabled {
        get
        set
    }
    MajorVersion {
        get
    }
    MinorVersion {
        get
    }
    NewVisualDesign {
        get
    }
    ButtonbarVisible {
        get
        set
    }
    StatusbarVisible {
        get
        set
    }
    TitlebarVisible {
        get
        set
    }
    ToolbarVisible {
        get
        set
    }
    Patchlevel {
        get
    }
    Revision {
        get
    }
    Utils {
        get
    }
}

class GuiBarChart extends GuiShell {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiVComponent extends GuiComponent {
    __New(comObj, policy := "", strict := false, path := "")
    Text {
        get
        set
    }
}

class GuiBox extends GuiVComponent {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiButton extends GuiVComponent {
    __New(comObj, policy := "", strict := false, path := "")
    Emphasized {
        get
    }
    LeftLabel {
        get
    }
    RightLabel {
        get
    }
}

class GuiCTextField extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiCalendar extends GuiShell {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiChart extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiCheckBox extends GuiVComponent {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiCollection extends SapCollectionProxy {
    __New(comObj, policy := "", strict := false, path := "")
    Item(index)
    ElementAt(index)
}

class GuiColorSelector extends GuiShell {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiComboBox extends GuiVComponent {
    __New(comObj, policy := "", strict := false, path := "")
    SetKeySpace(keySpace)
    Key {
        get
        set
    }
    Value {
        get
        set
    }
    CurListBoxEntry {
        get
    }
    ShowKey {
        get
        set
    }
}

class GuiComboBoxControl extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiComboBoxEntry extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiComponentCollection extends SapCollectionProxy {
    __New(comObj, policy := "", strict := false, path := "")
    Item(index)
    ElementAt(index)
}

class GuiConnection extends GuiContainer {
    __New(comObj, policy := "", strict := false, path := "/app/con[0]")
    CloseConnection()
    CloseSession(sessionId)
    ConnectionString {
        get
    }
    Description {
        get
    }
    DisabledByServer {
        get
    }
    Sessions {
        get
    }
}

class GuiContainerShell extends GuiVContainer {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiMenu extends GuiVContainer {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiContextMenu extends GuiMenu {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiCustomControl extends GuiVContainer {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiDialogShell extends GuiVContainer {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiEAIViewer2D extends GuiShell {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiEAIViewer3D extends GuiShell {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiEnum extends GuiVContainer {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiFrameWindow extends GuiVContainer {
    __New(comObj, policy := "", strict := false, path := "")
    Close()
    CompBitmap(scale, x, y, width, height)
    HardCopy(fileName, overwrite := unset)
    HardCopyToMemory()
    Iconify()
    IsVKeyAllowed(vkey)
    JumpBackward()
    JumpForward()
    Maximize()
    Restore()
    SendVKey(vkey)
    ShowMessageBox(type, text, caption := unset, defaultButton := unset)
    TabBackward()
    TabForward()
}

class GuiGOSShell extends GuiVContainer {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiGraphAdapt extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiGridView extends GuiShell {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiHTMLViewer extends GuiShell {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiInputFieldControl extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiLabel extends GuiVComponent {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiMainWindow extends GuiFrameWindow {
    __New(comObj, policy := "", strict := false, path := "")
    ResizeWorkingPane(width, height, throwOnFail := unset)
    ResizeWorkingPaneEx(width, height, throwOnFail := unset)
    ButtonbarVisible {
        get
        set
    }
    StatusbarVisible {
        get
        set
    }
    TitlebarVisible {
        get
        set
    }
    ToolbarVisible {
        get
        set
    }
}

class GuiMap extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiMenubar extends GuiVContainer {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiMessageWindow extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiModalWindow extends GuiFrameWindow {
    __New(comObj, policy := "", strict := false, path := "")
    PopupDialogText {
        get
    }
}

class GuiNetChart extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiOfficeIntegration extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiOkCodeField extends GuiVComponent {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiPasswordField extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiPicture extends GuiShell {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiRadioButton extends GuiVComponent {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiSapChart extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiScrollContainer extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiScrollbar extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiSession extends GuiContainer {
    __New(comObj, policy := "", strict := false, path := "/app/con[0]/ses[0]")
    FindById(id, raise := unset)
    AsStdNumberFormat(value)
    ClearErrorList()
    CreateSession()
    EnableJawsEvents(enable := unset)
    EndTransaction()
    FindByPosition(left, top, width := unset, height := unset)
    GetIconResourceName(iconName)
    GetVKeyDescription(vkey)
    LockSessionUI()
    SendCommand(command)
    StartTransaction(tcode)
    UnlockSessionUI()
    ActiveWindow {
        get
    }
    Info {
        get
    }
    Busy {
        get
    }
    ErrorList {
        get
    }
    IsActive {
        get
    }
    ProgressPercent {
        get
    }
    ProgressText {
        get
    }
    Record {
        get
        set
    }
    RecordFile {
        get
        set
    }
    SuppressBackendPopups {
        get
        set
    }
    TestToolMode {
        get
        set
    }
}

class GuiSessionInfo extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "")
    ApplicationServer {
        get
    }
    Client {
        get
    }
    Group {
        get
    }
    Language {
        get
    }
    Program {
        get
    }
    ScreenNumber {
        get
    }
    SystemName {
        get
    }
    SystemNumber {
        get
    }
    Transaction {
        get
    }
    User {
        get
    }
}

class GuiSimpleContainer extends GuiVContainer {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiSplit extends GuiShell {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiSplitterContainer extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiStage extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiStatusPane extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiStatusbar extends GuiVComponent {
    __New(comObj, policy := "", strict := false, path := "")
    DoubleClick()
    Handle {
        get
    }
    MessageAsPopup {
        get
    }
    MessageId {
        get
    }
    MessageNumber {
        get
    }
    MessageParameter {
        get
    }
    MessageType {
        get
    }
}

class GuiTab extends GuiVContainer {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiTabStrip extends GuiVContainer {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiTableColumn extends GuiComponentCollection {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiTableControl extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "")
    GetCell(row, col)
    GetAbsoluteRow(row)
    SelectAllColumns()
    DeselectAllColumns()
    ReorderTable(fromCol, toCol)
    ConfigureLayout(layoutName := unset)
    Columns {
        get
    }
    Rows {
        get
    }
    HorizontalScrollbar {
        get
    }
    VerticalScrollbar {
        get
    }
    RowCount {
        get
    }
    VisibleRowCount {
        get
    }
    CurrentCol {
        get
        set
    }
    CurrentRow {
        get
        set
    }
}

class GuiTableRow extends GuiComponentCollection {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiTextedit extends GuiShell {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiTitlebar extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiToolbar extends GuiVContainer {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiTree extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "")
    SelectNode(nodeKey)
    ExpandNode(nodeKey)
    CollapseNode(nodeKey)
    DoubleClickNode(nodeKey)
    GetNodeTextByPath(path)
    GetNodeKeyByPath(path)
    GetSelectedNodes()
    PressButton(buttonId)
    ColumnOrder {
        get
        set
    }
    SelectedNode {
        get
        set
    }
    TopNode {
        get
        set
    }
}

class GuiUserArea extends GuiVContainer {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiUtils extends SapComProxy {
    __New(comObj, policy := "", strict := false, path := "")
}

class GuiVHViewSwitch extends GuiVComponent {
    __New(comObj, policy := "", strict := false, path := "")
}
