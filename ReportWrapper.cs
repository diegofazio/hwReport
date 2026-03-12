using System;
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
    [Guid("A1B2C3D4-E5F6-4A1B-8C9D-E0F1A2B3C4D5")]
    [ComVisible(true)]
    [InterfaceType(ComInterfaceType.InterfaceIsIDispatch)]
    public interface IReportWrapper
    {
        bool LoadReport(string filePath);
        string GetLastError();
        
        // Data Management
        bool RegisterJsonData(string dataName, string jsonContent);
        void SetParameter(string name, string value);
        void SetCodePage(int codePage);
        
        // Component Manipulation
        bool SetText(string objectName, string text);
        bool SetImage(string objectName, string imagePath);
        bool SetBarcode(string objectName, string barcodeData);
        bool SetPosition(string objectName, float left, float top, float width, float height);
        bool SetVisible(string objectName, bool visible);
        void SetUnits(int unitType);
        
        // Runtime Object Creation
        bool AddTextObject(string bandName, string objectName, string text, float left, float top, float width, float height);
        bool AddPictureObject(string bandName, string objectName, string imagePath, float left, float top, float width, float height);
        
        // Property Settings
        bool SetFont(string objectName, string fontName, float size, bool bold, bool italic);
        bool SetAlignment(string objectName, int horz, int vert);
        bool SetColor(string objectName, string colorHtml);
        bool SetTextColor(string objectName, string colorHtml);
        
        // Execution
        bool ShowPreview();
        bool ExportToPdf(string exportPath, bool openAfter);
        bool ExportToHtml(string exportPath, bool openAfter);
        bool ExportToExcel(string exportPath, bool openAfter);
    }

    [Guid("B2C3D4E5-F6A1-4B2C-9D8E-F1A2B3C4D5E6")]
    [ComVisible(true)]
    [ClassInterface(ClassInterfaceType.None)]
    [ProgId("hwReport.FastReport")]
    public class ReportWrapper : IReportWrapper
    {
        private Report _report;
        private string _lastError = "";
        private DataSet _dataSet;
        private float _unitMultiplier = FastReport.Utils.Units.Centimeters;
        private int _codePage = 65001; // Default UTF-8 (Smart detection)

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

        public void SetParameter(string name, string value)
        {
            _report.SetParameterValue(name, ProcessString(value));
        }

        public void SetCodePage(int codePage)
        {
            _codePage = codePage;
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
                band.Objects.Add(txt); // Explicitly add to collection
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
                band.Objects.Add(pic); // Explicitly add to collection
                pic.Left = left * _unitMultiplier;
                pic.Top = top * _unitMultiplier;
                pic.Width = width * _unitMultiplier;
                pic.Height = height * _unitMultiplier;

                return true;
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
                obj.Font = new System.Drawing.Font(fontName, size, style);
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
                // Definitive fix for CS0234/CS0006 in OLE/COM + Costura environments:
                // 1. Clear any default references that might be using "short names"
                _report.ReferencedAssemblies = new string[0];
                var refs = new List<string>();

                // 2. Force load critical assemblies so they appear in AppDomain
                var forceLoad = new[] {
                    typeof(object), // mscorlib
                    typeof(System.Data.DataSet), // System.Data
                    typeof(Microsoft.CSharp.RuntimeBinder.Binder), // Microsoft.CSharp
                    typeof(System.Drawing.Image), // System.Drawing
                    typeof(System.Windows.Forms.Form), // System.Windows.Forms
                    typeof(System.Xml.XmlDocument), // System.Xml
                    _report.GetType() // FastReport
                };

                // 3. Collect absolute paths from currently loaded assemblies (includes Costura extractions)
                foreach (var assembly in AppDomain.CurrentDomain.GetAssemblies())
                {
                    try {
                        if (assembly.IsDynamic) continue;
                        string loc = assembly.Location;
                        if (!string.IsNullOrEmpty(loc) && !refs.Contains(loc)) refs.Add(loc);
                    } catch { }
                }

                // 4. If critical framework assemblies are still missing (not loaded yet), find them in GAC/Runtime
                string frameworkPath = System.Runtime.InteropServices.RuntimeEnvironment.GetRuntimeDirectory();
                string[] criticalNames = { "Microsoft.CSharp.dll", "System.Data.dll", "System.dll", "System.Core.dll", "System.Xml.dll", "System.Linq.dll" };
                foreach (var name in criticalNames)
                {
                    string fullPath = Path.Combine(frameworkPath, name);
                    if (File.Exists(fullPath) && !refs.Contains(fullPath)) refs.Add(fullPath);
                }

                _report.ReferencedAssemblies = refs.ToArray();
                debugInfo = "Refs: " + string.Join("; ", refs);

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
            try
            {
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
                _lastError = "HTML Export Error: " + ex.Message;
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
