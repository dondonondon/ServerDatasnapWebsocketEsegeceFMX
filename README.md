# Server Datasnap Esegece Websocket

Database : assets\database\inv_malay.sql
API : 
1. sources\models\restapi\ ~just add new unit with same structure with other.
2. Add Class YourClass = class
3. Add Function -> function FunctionName(Connection : TFDConnection; ADataRequest : TFDMemTable; out AStatusCode : Integer) : String;
4. Open sources\helpers\Datasnap.Core.Rest.pas
5. Go to procedure RegisterClassAPI;
5. Add your class here RegisterClasses([...,...,...,...,YourClass]);

# Config
Open config.ini in bin\configapps\config.ini

# UniGUI Apps If you want to try Apps (only EXE)

Package uniGUI : prjInventory.exe (only exe for sample if you want to try unigui apps)

unipackage-7.5.1 : https://blangkon.net/ProjectShare/Ext/unipackages-7.5.1.rar

ext-7.5.1.rar : https://blangkon.net/ProjectShare/Ext/ext-7.5.1.rar

uni.rar : https://blangkon.net/ProjectShare/Ext/uni.rar

Note : if you have error when run prjInventory.exe, check folder bin/log/...