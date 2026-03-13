On Error Resume Next
Set obj = CreateObject("hwReport.FastReport")
If Err.Number <> 0 Then
    WScript.Echo "ERROR: " & Err.Description
    WScript.Quit 1
End If

bitness = 0
bitness = obj.Bitness

If bitness = 0 Then
    WScript.Echo "OK (Bitness Unknown)"
Else
    WScript.Echo "OK (" & bitness & "-bit)"
End If
