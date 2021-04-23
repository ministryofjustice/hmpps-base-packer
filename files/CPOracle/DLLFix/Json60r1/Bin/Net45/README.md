Due to this webapp using 2 versions of Newtonsoft.Json.dll (6.0.0.0 & 9.0.0.0) we deploy the 6.0.0.0 dll to the GAC and the 9.0.0.0 is in the applications \bin folder

Reference: Newtonsoft.Json
  Newtonsoft.Json, Version=6.0.0.0, Culture=neutral, PublicKeyToken=30ad4fe6b2a6aeed
Source: NotFound
    6.0.0.0 by LondonCrc.Karma.Website, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null
    6.0.0.0 by System.Net.Http.Formatting, Version=5.2.3.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35
    6.0.0.0 by System.Web.Http, Version=5.2.3.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35
  Newtonsoft.Json, Version=9.0.0.0, Culture=neutral, PublicKeyToken=30ad4fe6b2a6aeed
Source: Local, Location: C:\inetpub\Karma-1.0.226.666\bin\Newtonsoft.Json.dll
    9.0.0.0 by LondonCrc.Karma.Service, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null
    9.0.0.0 by LondonCrc.Karma.Website, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null


to install 6.0.0.0 dll in the GAC we open powershell and run:
```
cd C:\Users\Administrator\Desktop\DLLFix\Json60r1\Bin\Net45> 
& 'C:\Program Files (x86)\Microsoft SDKs\Windows\v10.0A\bin\NETFX 4.8 Tools\gacutil.exe' -i .\Newtonsoft.Json.dll
```

GAC target is:
    C:\Windows\assembly\NativeImages_v4.0.30319_32\Newtonsoft.Json\2e42ae4e853635ea197525d08e01248b