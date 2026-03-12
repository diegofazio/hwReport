using System;
using System.Runtime.InteropServices;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Diagnostics;
using FastReport;
using FastReport.Export.PdfSimple;
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
        
        // Component Manipulation
        bool SetText(string objectName, string text);
        bool SetImage(string objectName, string imagePath);
        bool SetBarcode(string objectName, string barcodeData);
        bool SetPosition(string objectName, float leftCm, float topCm, float widthCm, float heightCm);
        bool SetVisible(string objectName, bool visible);
        
        // Execution
        bool ShowPreview();
        bool ExportToPdf(string exportPath, bool openAfter);
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
                var token = JToken.Parse(jsonContent);
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
            _report.SetParameterValue(name, value);
        }

        public bool SetText(string objectName, string text)
        {
            if (_report.FindObject(objectName) is TextObject obj)
            {
                obj.Text = text;
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

        public bool SetPosition(string objectName, float leftCm, float topCm, float widthCm, float heightCm)
        {
            if (_report.FindObject(objectName) is ReportComponentBase obj)
            {
                obj.Left = leftCm * FastReport.Utils.Units.Centimeters;
                obj.Top = topCm * FastReport.Utils.Units.Centimeters;
                obj.Width = widthCm * FastReport.Utils.Units.Centimeters;
                obj.Height = heightCm * FastReport.Utils.Units.Centimeters;
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

        public bool ExportToExcel(string exportPath, bool openAfter)
        {
            _lastError = "Excel export requires FastReport.Net Commercial version.";
            return false;
        }
    }
}
