[CmdletBinding()]
param(
    [string]$KeyFile = "hwReport.snk"
)

if (-not (Test-Path $KeyFile)) {
    Write-Host "Generando nueva clave de firma fuerte ($KeyFile)..."
    $bytes = [System.Reflection.StrongNameKeyPair]::new([uri]::new("https://raw.githubusercontent.com/dotnet/runtime/main/eng/StrongNamePublicKeys/MicrosoftShared.snk").ToString()).PublicKey
    # Note: StrongNameKeyPair doesn't actually let us generate a fresh RSA key to file natively in standard .NET 4.8 without interop.
    # The pure PowerShell way without relying on sn.exe or external binaries for a self-signed snk:
    # We will embed a tiny C# code to call the StrongName API.
    
    $code = @"
using System;
using System.IO;
using System.Runtime.InteropServices;

public class KeyGen
{
    [DllImport("mscoree.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    private static extern bool StrongNameFreeBuffer(IntPtr pbMemory);

    [DllImport("mscoree.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    private static extern bool StrongNameKeyGen(IntPtr wszKeyContainer, uint dwFlags, out IntPtr ppbKeyBlob, out uint pcbKeyBlob);

    public static byte[] Generate()
    {
        IntPtr keyBlob = IntPtr.Zero;
        uint keyBlobSize = 0;
        
        try {
            if (!StrongNameKeyGen(IntPtr.Zero, 0, out keyBlob, out keyBlobSize))
                throw new Exception("Error al generar StrongNameKey");
                
            byte[] bytes = new byte[keyBlobSize];
            Marshal.Copy(keyBlob, bytes, 0, (int)keyBlobSize);
            return bytes;
        } finally {
            if (keyBlob != IntPtr.Zero) StrongNameFreeBuffer(keyBlob);
        }
    }
}
"@
    Add-Type -TypeDefinition $code
    $snkBytes = [KeyGen]::Generate()
    [System.IO.File]::WriteAllBytes((Resolve-Path .\).Path + "\" + $KeyFile, $snkBytes)
    Write-Host "[$KeyFile] generado correctamente."
} else {
    Write-Host "[$KeyFile] ya existe. Omitiendo generación."
}
