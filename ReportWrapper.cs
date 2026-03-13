using System;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Diagnostics;
using FastReport;
using FastReport.Export.PdfSimple;
using FastReport.Export.Html;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace hwReport
{
    [Guid("D8E9F0A1-B2C3-4D5E-6F7A-8B9C0D1E2F3A")]
    [InterfaceType(ComInterfaceType.InterfaceIsIDispatch)]
    [ComVisible(true)]
    public interface IReportEvents
    {
        [DispId(1)]
        void OnUserFunctionCall();
    }

    [Guid("A1B2C3D4-E5F6-4A1B-8C9D-E0F1A2B3C4D5")]
    [ComVisible(true)]
    [InterfaceType(ComInterfaceType.InterfaceIsIDispatch)]
    public interface IReportWrapper
    {
        [DispId(1)]
        bool LoadReport(string filePath);
        [DispId(2)]
        string GetLastError();
        
        // Data Management
        [DispId(3)]
        bool RegisterJsonData(string dataName, string jsonContent);
        [DispId(4)]
        void SetParameter(string name, string value);
        [DispId(5)]
        void SetCodePage(int codePage);
        [DispId(6)]
        object Handler { get; set; }
        [DispId(7)]
        void SetHandler(object handler);
        
        // Component Manipulation
        [DispId(10)]
        bool SetText(string objectName, string text);
        [DispId(11)]
        bool SetImage(string objectName, string imagePath);
        [DispId(12)]
        bool SetBarcode(string objectName, string barcodeData);
        [DispId(13)]
        bool SetPosition(string objectName, float left, float top, float width, float height);
        [DispId(14)]
        bool SetVisible(string objectName, bool visible);
        [DispId(15)]
        void SetUnits(int unitType);
        
        // Runtime Object Creation
        [DispId(20)]
        bool AddTextObject(string bandName, string objectName, string text, float left, float top, float width, float height);
        [DispId(21)]
        bool AddPictureObject(string bandName, string objectName, string imagePath, float left, float top, float width, float height);
        [DispId(22)]
        bool AddHyperlinkObject(string bandName, string objectName, string text, string url, float left, float top, float width, float height);
        
        // Property Settings
        [DispId(30)]
        bool SetFont(string objectName, string fontName, float size, bool bold, bool italic);
        [DispId(31)]
        bool SetUnderline(string objectName, bool underline);
        [DispId(32)]
        bool SetAlignment(string objectName, int horz, int vert);
        [DispId(33)]
        bool SetColor(string objectName, string colorHtml);
        [DispId(34)]
        bool SetTextColor(string objectName, string colorHtml);
        [DispId(35)]
        bool SetHyperlink(string objectName, string url);
        
        // Callbacks
        [DispId(40)]
        bool RegisterUserFunction(string name, string parameters, string category, string description);
        [DispId(41)]
        bool Ping();
        [DispId(42)]
        void SetDiagnostics(bool enable);
        
        // Properties for Event Communication
        [DispId(50)]
        string EventMethodName { get; set; }
        [DispId(51)]
        object[] EventArgs { get; set; }
        [DispId(52)]
        object EventResult { get; set; }
        
        // Execution
        [DispId(60)]
        bool ShowPreview();
        [DispId(62)]
        bool ExportToPdf(string exportPath, bool openAfter);
        [DispId(63)]
        bool ExportToHtml(string exportPath, bool openAfter);
        [DispId(64)]
        bool ExportToExcel(string exportPath, bool openAfter);
    }

    [Guid("B2C3D4E5-F6A1-4B2C-9D8E-F1A2B3C4D5E6")]
    [ComVisible(true)]
    [ClassInterface(ClassInterfaceType.None)]
    [ComSourceInterfaces(typeof(IReportEvents))]
    [ProgId("hwReport.FastReport")]
    public class ReportWrapper : IReportWrapper
    {
        public delegate void UserFunctionCallEventHandler();
        public event UserFunctionCallEventHandler OnUserFunctionCall;

        private Report _report;
        private static object _handler;
        private static ReportWrapper _globalInstance;
        private string _lastError = "";
        private string _instanceId = Guid.NewGuid().ToString().Substring(0, 8);
        private DataSet _dataSet;
        private float _unitMultiplier = FastReport.Utils.Units.Centimeters;
        private int _codePage = 65001; // Default UTF-8 (Smart detection)
        private bool _bridgeEnabled = false;
        public static bool GlobalDiagnostics { get; set; } = true;

        public void SetDiagnostics(bool enable)
        {
            GlobalDiagnostics = enable;
        }

        // Properties for Event Communication
        public string EventMethodName { get; set; }
        public object[] EventArgs { get; set; }
        public object EventResult { get; set; }

        // Dynamic Functions
        private List<string> _dynamicScripts = new List<string>();

        public ReportWrapper()
        {
            _report = new Report();
            _dataSet = new DataSet("hwReportDS");
        }

        public string GetLastError() => _lastError;

        public bool LoadReport(string filePath)
        {
            try 
            {
                if (!File.Exists(filePath)) throw new FileNotFoundException("File not found", filePath);
                _report.Load(filePath);
                return true; 
            }
            catch (Exception ex) { _lastError = ex.Message; return false; }
        }

        public bool RegisterJsonData(string dataName, string jsonContent)
        {
            try
            {
                string processedJson = ProcessString(jsonContent);
                var token = JToken.Parse(processedJson);
                DataTable dt = new DataTable(dataName);

                if (token is JArray array)
                {
                    dt = JsonConvert.DeserializeObject<DataTable>(array.ToString());
                }
                else if (token is JObject obj)
                {
                    dt.Columns.Add("Key");
                    dt.Columns.Add("Value");
                    foreach (var prop in obj.Properties())
                    {
                        dt.Rows.Add(prop.Name, prop.Value.ToString());
                    }
                }

                if (dt != null)
                {
                    dt.TableName = dataName;
                    _report.RegisterData(dt, dataName);
                    
                    // Match the DataSource in the report dictionary and enable it
                    var ds = _report.GetDataSource(dataName);
                    if (ds != null) ds.Enabled = true;
                    
                    return true;
                }
                return false;
            }
            catch (Exception ex) { _lastError = "JSON Error: " + ex.Message; return false; }
        }

        public void SetParameter(string name, string value) => _report.SetParameterValue(name, ProcessString(value));

        public void SetCodePage(int codePage) => _codePage = codePage;

        public void SetHandler(object handler) 
        {
            if (GlobalDiagnostics) {
                Console.WriteLine("[C#] SetHandler: Instance={0}, HandlerIsNull={1}, C#Bitness={2}", 
                    _instanceId, handler == null, Environment.Is64BitProcess ? "64" : "32");
            }
            _handler = handler;
            _globalInstance = this;
            try { AppDomain.CurrentDomain.SetData("hwReport_Handler", handler); } catch { }
        }

        public object Handler
        {
            get { return GetHandler(); }
            set { SetHandler(value); }
        }

        public bool Ping() 
        {
            object h = GetHandler();
            if (GlobalDiagnostics) {
                Console.WriteLine("[C#] Ping: Instance={0}, HandlerStatus={1}", 
                    _instanceId, (h == null) ? "NULL" : "SET");
            }
            return h != null;
        }

        private object GetHandler()
        {
            if (_handler != null) return _handler;
            try { return AppDomain.CurrentDomain.GetData("hwReport_Handler"); } catch { return null; }
        }

        public static ReportWrapper GetGlobalInstance() 
        {
             if (_globalInstance == null)
             {
                 if (GlobalDiagnostics) {
                     Console.WriteLine("[C#] Warning: GetGlobalInstance requested but it is NULL!");
                 }
             }
             return _globalInstance;
        }

        private string ProcessString(string input)
        {
            if (string.IsNullOrEmpty(input) || _codePage == 0) return input;
            
            try 
            {
                // COM marshaling often widens ANSI/UTF-8 bytes into UTF-16 chars.
                // We use ISO-8859-1 (28591) to extract the original bytes 1:1.
                byte[] bytes = System.Text.Encoding.GetEncoding(28591).GetBytes(input);
                
                // If the user expects UTF-8, we check if the bytes are actually valid UTF-8
                // to avoid mangling strings that are already correct Unicode.
                if (_codePage == 65001 && !IsLikelyUTF8(bytes)) return input;

                return System.Text.Encoding.GetEncoding(_codePage).GetString(bytes);
            }
            catch { return input; }
        }

        private bool IsLikelyUTF8(byte[] bytes)
        {
            int i = 0;
            bool hasMultiByte = false;
            while (i < bytes.Length)
            {
                byte b = bytes[i];
                if (b <= 0x7F) { i++; continue; }
                if (b >= 0xC2 && b <= 0xDF) // 2-byte sequence
                {
                    if (i + 1 < bytes.Length && bytes[i + 1] >= 0x80 && bytes[i + 1] <= 0xBF) { i += 2; hasMultiByte = true; continue; }
                }
                else if (b >= 0xE0 && b <= 0xEF) // 3-byte sequence
                {
                    if (i + 2 < bytes.Length && bytes[i + 1] >= 0x80 && bytes[i + 1] <= 0xBF && bytes[i + 2] >= 0x80 && bytes[i + 2] <= 0xBF) { i += 3; hasMultiByte = true; continue; }
                }
                return false; // Not a valid UTF-8 sequence for our purposes
            }
            return hasMultiByte;
        }

        public void SetUnits(int unitType)
        {
            switch (unitType)
            {
                case 0: _unitMultiplier = FastReport.Utils.Units.Millimeters; break;
                case 1: _unitMultiplier = FastReport.Utils.Units.Centimeters; break;
                case 2: _unitMultiplier = FastReport.Utils.Units.Inches; break;
                case 3: _unitMultiplier = FastReport.Utils.Units.HundrethsOfInch; break;
                default: _unitMultiplier = FastReport.Utils.Units.Centimeters; break;
            }
        }

        public bool SetText(string objectName, string text)
        {
            if (_report.FindObject(objectName) is TextObject obj)
            {
                obj.Text = ProcessString(text);
                return true;
            }
            return false;
        }

        public bool SetImage(string objectName, string imagePath)
        {
            if (_report.FindObject(objectName) is PictureObject obj)
            {
                if (File.Exists(imagePath))
                {
                    obj.ImageLocation = imagePath;
                    return true;
                }
            }
            return false;
        }

        public bool SetBarcode(string objectName, string barcodeData)
        {
            // Note: FastReport OpenSource supports BarcodeObject via plugin or specific builds.
            // Casting generically to check if it's a barcode component.
            var obj = _report.FindObject(objectName);
            if (obj != null)
            {
                // Dynamic property set via reflection or specific type if known
                var prop = obj.GetType().GetProperty("Text");
                if (prop != null) { prop.SetValue(obj, barcodeData); return true; }
            }
            return false;
        }

        public bool SetPosition(string objectName, float left, float top, float width, float height)
        {
            if (_report.FindObject(objectName) is ReportComponentBase obj)
            {
                obj.Left = left * _unitMultiplier;
                obj.Top = top * _unitMultiplier;
                obj.Width = width * _unitMultiplier;
                obj.Height = height * _unitMultiplier;
                return true;
            }
            return false;
        }

        public bool SetVisible(string objectName, bool visible)
        {
            if (_report.FindObject(objectName) is ReportComponentBase obj)
            {
                obj.Visible = visible;
                return true;
            }
            return false;
        }

        public bool AddTextObject(string bandName, string objectName, string text, float left, float top, float width, float height)
        {
            try
            {
                BandBase band = _report.FindObject(bandName) as BandBase;
                if (band == null) { _lastError = $"Band '{bandName}' not found."; return false; }

                TextObject txt = new TextObject();
                txt.Name = objectName;
                txt.Text = ProcessString(text);
                txt.Parent = band;
                txt.Left = left * _unitMultiplier;
                txt.Top = top * _unitMultiplier;
                txt.Width = width * _unitMultiplier;
                txt.Height = height * _unitMultiplier;

                return true;
            }
            catch (Exception ex) { _lastError = ex.Message; return false; }
        }

        public bool AddPictureObject(string bandName, string objectName, string imagePath, float left, float top, float width, float height)
        {
            try
            {
                BandBase band = _report.FindObject(bandName) as BandBase;
                if (band == null) { _lastError = $"Band '{bandName}' not found."; return false; }

                PictureObject pic = new PictureObject();
                pic.Name = objectName;
                if (File.Exists(imagePath)) pic.ImageLocation = imagePath;
                pic.Parent = band;
                pic.Left = left * _unitMultiplier;
                pic.Top = top * _unitMultiplier;
                pic.Width = width * _unitMultiplier;
                pic.Height = height * _unitMultiplier;

                return true;
            }
            catch (Exception ex) { _lastError = ex.Message; return false; }
        }

        public bool AddHyperlinkObject(string bandName, string objectName, string text, string url, float left, float top, float width, float height)
        {
            try
            {
                if (!AddTextObject(bandName, objectName, text, left, top, width, height)) return false;

                if (_report.FindObject(objectName) is TextObject txt)
                {
                    txt.Hyperlink.Kind = HyperlinkKind.URL;
                    txt.Hyperlink.Value = url;
                    
                    // Default link styling: Blue and Underlined
                    txt.TextColor = System.Drawing.Color.Blue;
                    txt.Font = new System.Drawing.Font(txt.Font, txt.Font.Style | System.Drawing.FontStyle.Underline);
                    
                    return true;
                }
                return false;
            }
            catch (Exception ex) { _lastError = ex.Message; return false; }
        }

        public bool SetFont(string objectName, string fontName, float size, bool bold, bool italic)
        {
            if (_report.FindObject(objectName) is TextObject obj)
            {
                System.Drawing.FontStyle style = System.Drawing.FontStyle.Regular;
                if (bold) style |= System.Drawing.FontStyle.Bold;
                if (italic) style |= System.Drawing.FontStyle.Italic;
                if (obj.Font.Underline) style |= System.Drawing.FontStyle.Underline;
                
                obj.Font = new System.Drawing.Font(fontName, size, style);
                return true;
            }
            return false;
        }

        public bool SetUnderline(string objectName, bool underline)
        {
            if (_report.FindObject(objectName) is TextObject obj)
            {
                System.Drawing.FontStyle style = obj.Font.Style;
                if (underline) style |= System.Drawing.FontStyle.Underline;
                else style &= ~System.Drawing.FontStyle.Underline;
                
                obj.Font = new System.Drawing.Font(obj.Font, style);
                return true;
            }
            return false;
        }

        public bool SetAlignment(string objectName, int horz, int vert)
        {
            if (_report.FindObject(objectName) is TextObject obj)
            {
                obj.HorzAlign = (HorzAlign)horz;
                obj.VertAlign = (VertAlign)vert;
                return true;
            }
            return false;
        }

        public bool SetColor(string objectName, string colorHtml)
        {
            var obj = _report.FindObject(objectName);
            if (obj is ReportComponentBase comp)
            {
                try {
                    comp.Fill = new SolidFill(System.Drawing.ColorTranslator.FromHtml(colorHtml));
                    return true;
                } catch { }
            }
            return false;
        }

        public bool SetTextColor(string objectName, string colorHtml)
        {
            if (_report.FindObject(objectName) is TextObject obj)
            {
                try {
                    obj.TextColor = System.Drawing.ColorTranslator.FromHtml(colorHtml);
                    return true;
                } catch { }
            }
            return false;
        }

        public bool SetHyperlink(string objectName, string url)
        {
            if (_report.FindObject(objectName) is ReportComponentBase obj)
            {
                obj.Hyperlink.Kind = HyperlinkKind.URL;
                obj.Hyperlink.Value = url;
                return true;
            }
            return false;
        }

        public bool RegisterUserFunction(string name, string parameters, string category, string description)
        {
            _bridgeEnabled = true;

            // Generate the dynamic C# wrapper method
            // e.g., name="FormatCurrency", parameters="object p1"
            string paramList = parameters == null ? "" : parameters.Trim();
            
            // Extract just the parameter names to pass to HB.Call
            // "object p1, string p2" -> "p1, p2"
            string varNames = "";
            if (!string.IsNullOrEmpty(paramList))
            {
                string[] parts = paramList.Split(',');
                for (int i = 0; i < parts.Length; i++)
                {
                    string part = parts[i].Trim();
                    int lastSpace = part.LastIndexOf(' ');
                    if (lastSpace != -1)
                    {
                        varNames += part.Substring(lastSpace + 1);
                        if (i < parts.Length - 1) varNames += ", ";
                    }
                }
            }
            
            string methodDef = string.Format("\n        // Registered from Harbour: {0}\n", description) +
                               string.Format("        public object {0}({1})\n", name, paramList) +
                               string.Format("        {{\n            return HB.Call(\"{0}\"{1});\n        }}\n", 
                                             name, string.IsNullOrEmpty(varNames) ? "" : ", " + varNames);

            if (!_dynamicScripts.Contains(methodDef))
            {
                _dynamicScripts.Add(methodDef);
            }

            // Register with FastReport IDE so it shows in the "Data" tree
            // Since we can't easily emit MethodInfo at runtime in standard .NET 4.8 without Reflection.Emit,
            // we will rely on injecting the script. The function will be valid in the parser.
            // (Note: To show in the Data Tree natively, we would need a pre-compiled MethodInfo, 
            // but the FastReport compiler will compile our injected script and it will work perfectly in expressions).

            return true;
        }

        private string SetupReportEnvironment()
        {
            _globalInstance = this; // Ensure we are tracked
            string debugInfo = "";
            
            // 1. Clear and rebuild references
            _report.ReferencedAssemblies = new string[0];
            var refs = new List<string>();

            // Force load critical assemblies
            var forceLoad = new[] {
                typeof(object), // mscorlib
                typeof(System.Data.DataSet), // System.Data
                typeof(Microsoft.CSharp.RuntimeBinder.Binder), // Microsoft.CSharp
                typeof(System.Drawing.Image), // System.Drawing
                typeof(System.Windows.Forms.Form), // System.Windows.Forms
                typeof(System.Xml.XmlDocument), // System.Xml
                _report.GetType() // FastReport
            };

            foreach (var assembly in AppDomain.CurrentDomain.GetAssemblies())
            {
                try {
                    if (assembly.IsDynamic) continue;
                    string loc = assembly.Location;
                    if (!string.IsNullOrEmpty(loc) && !refs.Contains(loc)) refs.Add(loc);
                } catch { }
            }

            string frameworkPath = System.Runtime.InteropServices.RuntimeEnvironment.GetRuntimeDirectory();
            string[] criticalNames = { "Microsoft.CSharp.dll", "System.Data.dll", "System.dll", "System.Core.dll", "System.Xml.dll", "System.Linq.dll" };
            foreach (var name in criticalNames)
            {
                string fullPath = Path.Combine(frameworkPath, name);
                if (File.Exists(fullPath) && !refs.Contains(fullPath)) refs.Add(fullPath);
            }

            _report.ReferencedAssemblies = refs.ToArray();
            debugInfo = "Refs: " + string.Join("; ", refs);

            // 2. Inject Script Bridge if enabled
            if (_bridgeEnabled)
            {
                _report.SetParameterValue("HB_Instance", this);
                if (_handler != null) _report.SetParameterValue("HB_Handler", _handler);
                
                // Smarter bridge: try to find the instance that has the handler
                string bridge = @"
        public hwReport.ReportWrapper HB 
        { 
            get 
            { 
                var inst = Report.GetParameterValue(""HB_Instance"") as hwReport.ReportWrapper;
                if (inst == null || !inst.Ping()) inst = hwReport.ReportWrapper.GetGlobalInstance();
                return inst;
            } 
        }";

                // Append all dynamic user functions
                foreach (string script in _dynamicScripts)
                {
                    bridge += script;
                }
                
                if (string.IsNullOrEmpty(_report.ScriptText))
                {
                    _report.ScriptText = "using System;\nusing hwReport;\n\nnamespace FastReport\n{\n  public class ReportScript\n  {\n    " + bridge + "\n  }\n}";
                }
                else if (!_report.ScriptText.Contains("public hwReport.ReportWrapper HB"))
                {
                    int classPos = _report.ScriptText.IndexOf("public class ReportScript");
                    if (classPos != -1)
                    {
                        int openBrace = _report.ScriptText.IndexOf("{", classPos);
                        if (openBrace != -1)
                        {
                            _report.ScriptText = _report.ScriptText.Insert(openBrace + 1, "\n    " + bridge + "\n");
                        }
                    }
                }
            }

            return debugInfo;
        }

        // Bridge method callable from FastReport Script
        public object Call(string name, object p1 = null, object p2 = null, object p3 = null)
        {
            // If we have a direct handler (rare but possible), use it
            object h = GetHandler();
            if (h != null)
            {
                try {
                    dynamic dh = h;
                    return dh.OnUserFunctionCall(name, new object[] { p1, p2, p3 });
                } catch { /* Fallback to Event Subsystem */ }
            }

            // Sync OLE Event
            EventMethodName = name;
            EventArgs = new object[] { p1, p2, p3 };
            EventResult = null;

            if (OnUserFunctionCall != null)
            {
                OnUserFunctionCall(); // Fire synchronous event, Harbour code will execute here
            }
            else
            {
                return "Error: Harbour did not register the event using __axRegisterHandler.";
            }

            return EventResult;
        }

        public bool ShowPreview()
        {
            return ExportToPdfInternal(null, true);
        }

        public bool ExportToPdf(string exportPath, bool openAfter)
        {
            return ExportToPdfInternal(exportPath, openAfter);
        }

        private bool ExportToPdfInternal(string exportPath, bool openAfter)
        {
            string debugInfo = "";
            try
            {
                debugInfo = SetupReportEnvironment();
                _report.Prepare();
                string target = exportPath;
                if (string.IsNullOrEmpty(target))
                {
                    target = Path.Combine(Path.GetTempPath(), $"report_{Guid.NewGuid():N}.pdf");
                }
                
                using (var pdfExport = new PDFSimpleExport())
                {
                    _report.Export(pdfExport, target);
                }

                if (openAfter)
                {
                    Process.Start(new ProcessStartInfo(target) { UseShellExecute = true });
                }
                return true;
            }
            catch (Exception ex) 
            { 
                _lastError = ex.Message + (string.IsNullOrEmpty(debugInfo) ? "" : "\nDebug: " + debugInfo); 
                return false; 
            }
        }

        public bool ExportToHtml(string exportPath, bool openAfter)
        {
            string debugInfo = "";
            try
            {
                debugInfo = SetupReportEnvironment();
                _report.Prepare();
                string target = exportPath;
                if (string.IsNullOrEmpty(target))
                {
                    target = Path.Combine(Path.GetTempPath(), $"report_{Guid.NewGuid():N}.html");
                }

                using (var htmlExport = new HTMLExport())
                {
                    htmlExport.SinglePage = true;
                    htmlExport.EmbedPictures = true;
                    _report.Export(htmlExport, target);
                }

                if (openAfter)
                {
                    Process.Start(new ProcessStartInfo(target) { UseShellExecute = true });
                }
                return true;
            }
            catch (Exception ex)
            {
                _lastError = "HTML Export Error: " + ex.Message + (string.IsNullOrEmpty(debugInfo) ? "" : "\nDebug: " + debugInfo);
                return false;
            }
        }

        public bool ExportToExcel(string exportPath, bool openAfter)
        {
            _lastError = "Excel export requires FastReport.Net Commercial version.";
            return false;
        }
    }
}
